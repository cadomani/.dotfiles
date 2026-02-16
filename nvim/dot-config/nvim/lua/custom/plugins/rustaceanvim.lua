---@type LazySpec
return {
  {
    'mrcjkb/rustaceanvim',
    version = '^6',
    lazy = false,
    config = function()
      vim.g.rustaceanvim = {
        -- Plugin configuration
        ---@type rustaceanvim.tools.Opts
        tools = {
          float_win_config = {
            border = 'rounded',
          },
          crate_test_executor = 'neotest',
          test_executor = 'neotest',
        },
        -- LSP configuration
        server = {
          on_attach = function(_, bufnr)
            local opts = { silent = true, buffer = bufnr }

            -- Use rust-analyzer's grouping for code actions
            vim.keymap.set('n', '<leader>ca', function()
              vim.cmd.RustLsp 'codeAction'
            end, vim.tbl_extend('force', opts, { desc = 'LSP: Code Action (Rust)' }))

            -- Also support visual mode for code actions
            vim.keymap.set('x', '<leader>ca', function()
              vim.cmd.RustLsp 'codeAction'
            end, vim.tbl_extend('force', opts, { desc = 'LSP: Code Action (Rust)' }))

            -- Override Neovim's built-in hover keymap with rustaceanvim's hover actions
            vim.keymap.set('n', 'K', function()
              vim.cmd.RustLsp { 'hover', 'actions' }
            end, vim.tbl_extend('force', opts, { desc = 'LSP: Hover Actions (Rust)' }))

            -- Rename (uses standard LSP rename)
            vim.keymap.set('n', '<leader>cr', vim.lsp.buf.rename, vim.tbl_extend('force', opts, { desc = 'LSP: Rename' }))

            -- Line diagnostics
            vim.keymap.set('n', '<leader>cd', vim.diagnostic.open_float, vim.tbl_extend('force', opts, { desc = 'LSP: Line Diagnostics' }))
          end,
          default_settings = {
            -- rust-analyzer language server configuration
            ['rust-analyzer'] = {
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                buildScripts = {
                  enable = true,
                },
              },
              diagnostics = {
                enable = true,
                experimental = {
                  enable = true,
                },
              },
              procMacro = {
                enable = true,
                -- ignored = {
                --   ['async-trait'] = { 'async_trait' },
                --   ['napi-derive'] = { 'napi' },
                --   ['async-recursion'] = { 'async_recursion' },
                -- },
              },
              files = {
                exclude = {
                  '.direnv',
                  '.git',
                  '.jj',
                  '.github',
                  '.gitlab',
                  'bin',
                  'node_modules',
                  'target',
                  'venv',
                  '.venv',
                },
                -- Avoid Roots Scanned hanging, see https://github.com/rust-lang/rust-analyzer/issues/12613#issuecomment-2096386344
                watcher = 'client',
              },
            },
          },
        },
        -- DAP configuration
        dap = {},
      }
    end,
  },
  {
    'nvim-neotest/neotest',
    optional = true,
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      vim.list_extend(opts.adapters, {
        require 'rustaceanvim.neotest',
      })
    end,
  },
}
