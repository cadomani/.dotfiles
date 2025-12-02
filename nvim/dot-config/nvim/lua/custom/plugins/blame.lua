return {
  {
    'FabijanZulj/blame.nvim',
    lazy = false,
    config = function()
      require('blame').setup {
        date_format = '%d.%m.%Y',
        virtual_style = 'right_align',
        focus_blame = true,
        merge_consecutive = true,
        max_summary_width = 30,
        colors = nil,
        blame_options = nil,
        commit_detail_view = 'vsplit',
        mappings = {
          commit_info = 'i',
          stack_push = '<TAB>',
          stack_pop = '<BS>',
          show_commit = '<CR>',
          close = { '<esc>', 'q' },
        },
      }
    end,
    keys = {
      { '<leader>gb', '<cmd>BlameToggle<CR>', desc = 'Git Blame' },
    },
  },
}
