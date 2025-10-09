return {
  'cordx56/rustowl',
  version = '*',
  build = 'cargo binstall rustowl',
  lazy = false, -- This plugin is already lazy
  opts = {
    client = {
      on_attach = function(_, buffer)
        vim.keymap.set('n', '<leader>ro', function()
          require('rustowl').toggle(buffer)
        end, { buffer = buffer, desc = 'Toggle RustOwl' })
      end,
    },
  },
}
