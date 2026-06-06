-- Nix Language Support
--
-- This module wires up Nix tooling for both NixOS and macOS+Nix machines.
--
-- IMPORTANT: nixd (the LSP) and nixfmt (the formatter) are intentionally NOT
-- installed via Mason. Mason downloads prebuilt binaries that do not run on
-- NixOS (non-standard dynamic linker), so we rely on the tools being on PATH,
-- installed through Nix itself. This works identically everywhere.
--
-- Install the tools per platform:
--   NixOS:        add `nixd` and `nixfmt-rfc-style` to environment.systemPackages
--                 (or home.packages), then `sudo nixos-rebuild switch`.
--   Home Manager: add them to home.packages, then `home-manager switch`.
--   macOS (Nix):  nix profile install nixpkgs#nixd nixpkgs#nixfmt-rfc-style
--   macOS (brew): brew install nixd nixfmt
--
-- nixd's killer feature is options auto-completion. It can complete NixOS /
-- Home Manager / nix-darwin options against your real config once you point the
-- `options` settings below at your flake outputs. The defaults here enable
-- nixpkgs/lib completion out of the box; see the commented examples to enable
-- per-host options completion once your flake exists.

return {
  -- nixd LSP configuration
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'saghen/blink.cmp' },
    config = function()
      -- Only configure nixd if it is actually available on PATH. On a fresh
      -- machine that hasn't installed it yet, nudge the user instead of leaving
      -- a broken LSP that fails to spawn.
      if vim.fn.executable 'nixd' ~= 1 then
        vim.api.nvim_create_autocmd('FileType', {
          pattern = 'nix',
          once = true,
          callback = function()
            local install = vim.fn.has 'mac' == 1 and 'nix profile install nixpkgs#nixd nixpkgs#nixfmt-rfc-style (or: brew install nixd nixfmt)'
              or 'add `nixd` to environment.systemPackages / home.packages, then rebuild'
            vim.notify('nixd not found on PATH. To enable the Nix LSP: ' .. install, vim.log.levels.WARN)
          end,
        })
        return
      end

      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- Pick the formatter command nixd should invoke for `textDocument/formatting`.
      -- Prefer nixfmt (the official RFC 166 formatter); fall back to alejandra
      -- or nixpkgs-fmt if that's what happens to be installed.
      local format_cmd
      if vim.fn.executable 'nixfmt' == 1 then
        format_cmd = { 'nixfmt' }
      elseif vim.fn.executable 'alejandra' == 1 then
        format_cmd = { 'alejandra' }
      elseif vim.fn.executable 'nixpkgs-fmt' == 1 then
        format_cmd = { 'nixpkgs-fmt' }
      end

      vim.lsp.config('nixd', {
        capabilities = capabilities,
        cmd = { 'nixd' },
        filetypes = { 'nix' },
        root_markers = { 'flake.nix', '.git' },
        settings = {
          nixd = {
            nixpkgs = {
              -- Used as the base for nixpkgs/lib completion and evaluation.
              expr = 'import <nixpkgs> { }',
            },
            formatting = format_cmd and { command = format_cmd } or nil,
            -- Options completion. The expressions below evaluate your flake
            -- outputs so nixd can complete option names/types/docs. They are
            -- commented out because they depend on your flake's structure and
            -- host/user names. Uncomment and adjust once your flake exists.
            --
            -- Tip: from your flake dir, `nix repl` then `:lf .` and inspect
            -- `nixosConfigurations`, `darwinConfigurations`, `homeConfigurations`
            -- to find the exact attribute names to plug in below.
            options = {
              -- NixOS options (replace <hostname>):
              -- nixos = {
              --   expr = '(builtins.getFlake "/path/to/flake").nixosConfigurations.<hostname>.options',
              -- },
              -- Home Manager options (replace <user@hostname> or your key):
              -- home_manager = {
              --   expr = '(builtins.getFlake "/path/to/flake").homeConfigurations.<key>.options',
              -- },
              -- nix-darwin options on macOS (replace <hostname>):
              -- darwin = {
              --   expr = '(builtins.getFlake "/path/to/flake").darwinConfigurations.<hostname>.options',
              -- },
            },
          },
        },
      })
      vim.lsp.enable 'nixd'
    end,
  },

  -- Nix Treesitter parser (syntax highlighting, text objects, folds)
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { 'nix' })
    end,
  },

  -- Format Nix files on save with nixfmt (via conform.nvim).
  -- lazy.nvim deep-merges this opts table with conform's other specs.
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        nix = { 'nixfmt', 'alejandra', 'nixpkgs-fmt', stop_after_first = true },
      },
    },
  },
}
