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
          test_executor = 'background',
        },
        -- LSP configuration
        server = {
          on_attach = function(_, bufnr)
            -- Use rust-analyzer's grouping
            vim.keymap.set('n', '<leader>ca', function()
              vim.cmd.RustLsp 'codeAction'
              -- uncomment to use vim's default grouping
              -- vim.lsp.buf.codeAction()
            end, { silent = true, buffer = bufnr })

            -- Override Neovim's built-in hover keymap with rustaceanvim's hover actions
            vim.keymap.set('n', 'K', function()
              vim.cmd.RustLsp { 'hover', 'actions' }
            end, { silent = true, buffer = bufnr })
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
                ignored = {
                  ['async-trait'] = { 'async_trait' },
                  ['napi-derive'] = { 'napi' },
                  ['async-recursion'] = { 'async_recursion' },
                },
              },
              files = {
                excludeDirs = {
                  '.direnv',
                  '.git',
                  '.github',
                  '.gitlab',
                  'bin',
                  'node_modules',
                  'target',
                  'venv',
                  '.venv',
                },
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
