return {
  'LintaoAmons/bookmarks.nvim',
  -- pin the plugin at specific version for stability
  -- backup your bookmark sqlite db when there are breaking changes
  -- tag = "v2.3.0",
  dependencies = {
    { 'kkharji/sqlite.lua' },
    { 'nvim-telescope/telescope.nvim' },
    { 'stevearc/dressing.nvim' }, -- optional: better UI
  },
  config = function()
    local opts = {} -- check the "./lua/bookmarks/default-config.lua" file for all the options
    require('bookmarks').setup(opts) -- you must call setup to init sqlite db

    require('bookmarks').setup {
      picker = function()
        require('snacks.picker').pick('files', { prompt = 'Select Bookmark' })
      end,
      on_attach = function(bufnr)
        local bm = require 'bookmarks'
        local map = vim.keymap.set
        map('n', '<leader>mm', bm.bookmark_toggle) -- Add or remove bookmark at current line
        map('n', '<leader>mi', bm.bookmark_ann) -- Add or edit bookmark annotation at current line
        map('n', '<leader>mc', bm.bookmark_clean) -- Clean all bookmarks in local buffer
        map('n', '<leader>mn', bm.bookmark_next) -- Jump to next bookmark in local buffer
        map('n', '<leader>mp', bm.bookmark_prev) -- Jump to previous bookmark in local buffer
        map('n', '<leader>ml', bm.bookmark_list) -- Show bookmark list in picker
        map('n', '<leader>mx', bm.bookmark_clear_all) -- Remove all bookmarks
      end,
    }
  end,
}
