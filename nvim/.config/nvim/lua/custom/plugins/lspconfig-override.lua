-- Custom LSP keymaps and hover behavior
-- Navigation (gd, gr, gI, gt) is handled by snacks.nvim
-- This adds additional keymaps on LspAttach
return {
  {
    'neovim/nvim-lspconfig',
    init = function()
      -- Add custom keymaps when LSP attaches
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('custom-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Custom keymaps (in addition to snacks.nvim navigation)
          map('<leader>cr', vim.lsp.buf.rename, 'Rename')
          map('<leader>ca', vim.lsp.buf.code_action, 'Code Action', { 'n', 'x' })
          map('<leader>cd', vim.diagnostic.open_float, 'Line Diagnostics')

          -- Enhanced hover with border and dimensions
          map('K', function()
            vim.lsp.buf.hover {
              border = 'rounded',
              max_width = 100,
              max_height = 40,
              wrap = true,
              focus = false,
              close_events = { 'CursorMoved', 'BufHidden', 'InsertCharPre' },
            }
          end, 'Code Hover')
        end,
      })
    end,
  },
}
