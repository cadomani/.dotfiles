return {
  {
    'mrcjkb/rustaceanvim',
    version = '^5',
    lazy = false,
    config = function()
      vim.g.rustaceanvim = {
        -- Plugin configuration
        tools = {},
        -- LSP configuration
        server = {
          on_attach = function(client, bufnr)
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
            -- LSP configuration
            ['rust-analyzer'] = {
              diagnostics = {
                disabled = { 'inactive-code' },
              },
            },
          },
        },
        -- DAP configuration
        dap = {},
      }
    end,
  },
}
