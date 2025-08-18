---@type LazySpec
return {
  'chrisgrieser/nvim-origami',
  event = 'VeryLazy',
  ---@type Origami.config
  opts = {
    foldtext = {
      enabled = false,
      padding = 3,
      lineCount = {
        template = '%d lines', -- `%d` replaced with number of folded lines
        hlgroup = 'Comment',
      },
    },
    autoFold = {
      enabled = true,
      kinds = { 'comment', 'imports' },
    },
    foldKeymaps = {
      setup = true,
      hOnlyOpensOnFirstColumn = false,
    },
  },

  -- Disable vim's auto-folding
  init = function()
    vim.opt.foldlevel = 99
    vim.opt.foldlevelstart = 99
  end,
}
