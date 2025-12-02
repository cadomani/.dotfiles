-- Telescope kept for bookmarks.nvim dependency, but keymaps disabled
-- Using snacks.nvim picker for all search/navigation (see snacks.lua)
return {
  {
    'nvim-telescope/telescope.nvim',
    -- Don't load on VimEnter, let bookmarks.nvim load it when needed
    event = {},
    keys = {},
    config = function()
      -- Minimal setup without keymaps - keymaps handled by snacks.nvim
      require('telescope').setup {
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')
    end,
  },
}
