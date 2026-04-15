-- Custom keymaps
-- These are applied AFTER kickstart's keymaps.lua

-- Save file with Ctrl+S
vim.keymap.set({ 'i', 'x', 'n', 's' }, '<C-s>', '<cmd>w<cr><esc>', { desc = 'Save File' })

-- Move lines up/down with Alt+J/K
vim.keymap.set('n', '<A-j>', "<cmd>execute 'move .+' . v:count1<cr>==", { desc = 'Move Down' })
vim.keymap.set('n', '<A-k>', "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = 'Move Up' })
vim.keymap.set('i', '<A-j>', '<esc><cmd>m .+1<cr>==gi', { desc = 'Move Down' })
vim.keymap.set('i', '<A-k>', '<esc><cmd>m .-2<cr>==gi', { desc = 'Move Up' })
vim.keymap.set('v', '<A-j>', ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = 'Move Down' })
vim.keymap.set('v', '<A-k>', ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = 'Move Up' })

-- Stay in visual mode after indent
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- Remap diagnostic quickfix (upstream uses <leader>q, we use <leader>cq)
vim.keymap.del('n', '<leader>q')
vim.keymap.set('n', '<leader>cq', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Redraw / Clear hlsearch / Diff Update
vim.keymap.set('n', '<leader>ur', '<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>', { desc = 'Redraw / Clear hlsearch / Diff Update' })

-- Better search navigation (center on search result)
vim.keymap.set('n', 'n', "'Nn'[v:searchforward].'zv'", { expr = true, desc = 'Next Search Result' })
vim.keymap.set('x', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next Search Result' })
vim.keymap.set('o', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next Search Result' })
vim.keymap.set('n', 'N', "'nN'[v:searchforward].'zv'", { expr = true, desc = 'Prev Search Result' })
vim.keymap.set('x', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Prev Search Result' })
vim.keymap.set('o', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Prev Search Result' })

-- Window splits
vim.keymap.set('n', '<leader>-', '<C-W>s', { desc = 'Split Window Below', remap = true })
vim.keymap.set('n', '<leader>|', '<C-W>v', { desc = 'Split Window Right', remap = true })
vim.keymap.set('n', '<leader>wd', '<C-W>c', { desc = 'Close Window', remap = true })

-- Undo breakpoints (create undo points at punctuation)
vim.keymap.set('i', ',', ',<c-g>u')
vim.keymap.set('i', '.', '.<c-g>u')
vim.keymap.set('i', ';', ';<c-g>u')

-- Command abbreviations
vim.cmd.cabbrev('Qa', 'qa')

-- LSP restart
vim.keymap.set('n', '<leader>lr', function()
  vim.cmd 'LspRestart'
  vim.notify('LSP restarted', vim.log.levels.INFO)
end, { desc = 'LSP: Restart' })

-- LSP hard resync: reload all file buffers from disk, then notify all LSP
-- clients about every changed file in a single batched notification.
vim.keymap.set('n', '<leader>lR', function()
  local changes = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == '' then
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= '' and vim.fn.filereadable(name) == 1 then
        vim.api.nvim_buf_call(buf, function()
          vim.cmd 'e!'
        end)
        table.insert(changes, {
          uri = vim.uri_from_fname(name),
          type = 2, -- Changed
        })
      end
    end
  end

  if #changes > 0 then
    for _, client in ipairs(vim.lsp.get_clients()) do
      if client:supports_method('workspace/didChangeWatchedFiles') then
        client:notify('workspace/didChangeWatchedFiles', { changes = changes })
      end
    end
  end

  vim.notify(('Resynced %d buffer(s)'):format(#changes), vim.log.levels.INFO)
end, { desc = 'LSP: Hard Resync All Buffers' })

-- C++ specific keymaps
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'c', 'cpp' },
  callback = function()
    local opts = { buffer = true }
    -- Switch between header and source file
    vim.keymap.set('n', '<leader>gh', '<cmd>ClangdSwitchSourceHeader<cr>', vim.tbl_extend('force', opts, { desc = 'Switch Header/Source' }))

    -- Show type hierarchy
    vim.keymap.set('n', '<leader>gt', '<cmd>ClangdTypeHierarchy<cr>', vim.tbl_extend('force', opts, { desc = 'Type Hierarchy' }))

    -- Show symbol info
    vim.keymap.set('n', '<leader>gs', '<cmd>ClangdSymbolInfo<cr>', vim.tbl_extend('force', opts, { desc = 'Symbol Info' }))
  end,
})
