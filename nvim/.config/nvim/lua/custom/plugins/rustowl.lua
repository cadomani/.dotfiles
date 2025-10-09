return {
  'cordx56/rustowl',
  version = '*',
  build = 'cargo binstall rustowl',
  lazy = false, -- This plugin is already lazy
  ---@type rustowl.Config
  opts = {
    auto_attach = false,
    auto_enable = false,
    client = {
      on_attach = function(_, buffer)
        vim.keymap.set('n', '<leader>ro', function()
          require('rustowl').toggle(buffer)
        end, { buffer = buffer, desc = 'Toggle RustOwl' })
      end,
    },
  },
}
