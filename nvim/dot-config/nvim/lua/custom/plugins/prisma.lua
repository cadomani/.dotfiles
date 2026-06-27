-- Prisma schema support (prismals language server)
--
-- The Mason package `prisma-language-server` is registered in
-- kickstart/plugins/lspconfig.lua's ensure_installed list. nvim-lspconfig ships
-- the default prismals config (cmd/filetypes/root_markers), so here we only layer
-- on blink.cmp capabilities and enable the server, matching the typescript/nix setup.
--
-- Formatting works out of the box: prismals provides LSP formatting and conform's
-- format_on_save falls back to the LSP for the `prisma` filetype.
return {
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'saghen/blink.cmp' },
    opts = function(_, opts)
      local capabilities = require('blink.cmp').get_lsp_capabilities()
      vim.lsp.config('prismals', {
        capabilities = capabilities,
      })
      vim.lsp.enable 'prismals'
      return opts
    end,
  },
}
