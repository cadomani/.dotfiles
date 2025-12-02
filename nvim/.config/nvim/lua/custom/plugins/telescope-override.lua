-- Override telescope styling
-- Keymaps are handled by snacks.nvim, this just customizes the dropdown theme
return {
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    opts = {
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown {
            sorting_strategy = 'ascending',
            layout_config = {
              prompt_position = 'top',
            },
          },
        },
      },
    },
  },
}
