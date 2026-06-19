return {
  {
    'folke/sidekick.nvim',
    dependencies = {
      'folke/snacks.nvim',
      { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main' },
    },
    opts = {
      -- Next Edit Suggestions require a Copilot subscription/LSP. We only want the
      -- CLI integration, so keep NES off to avoid the status nags.
      nes = { enabled = false },
      copilot = { status = { enabled = false } },
      cli = {
        -- Reload buffers when the agent edits files on disk.
        watch = true,
        -- Run the agent in a real zellij pane when nvim was launched inside zellij.
        -- zellij renders the TUI itself, sidestepping the in-editor terminal redraw
        -- glitches. Falls back to an in-nvim terminal when not inside zellij.
        mux = {
          backend = 'zellij',
          enabled = vim.env.ZELLIJ ~= nil,
          create = 'terminal',
          split = { vertical = true, size = 0.5 },
        },
      },
    },
    keys = {
      { '<leader>a', nil, desc = 'AI / Sidekick' },
      {
        '<C-,>',
        function()
          require('sidekick.cli').toggle { name = 'claude', focus = true }
        end,
        mode = { 'n', 't' },
        desc = 'Toggle Claude',
      },
      {
        '<C-.>',
        function()
          require('sidekick.cli').focus()
        end,
        mode = { 'n', 't', 'i', 'x' },
        desc = 'Focus Sidekick (toggle to/from CLI)',
      },
      {
        '<leader>aa',
        function()
          require('sidekick.cli').toggle()
        end,
        desc = 'Toggle CLI',
      },
      {
        '<leader>ac',
        function()
          require('sidekick.cli').toggle { name = 'claude', focus = true }
        end,
        desc = 'Toggle Claude',
      },
      {
        '<leader>as',
        function()
          require('sidekick.cli').select()
        end,
        desc = 'Select CLI',
      },
      {
        '<leader>ad',
        function()
          require('sidekick.cli').close()
        end,
        desc = 'Detach CLI session',
      },
      {
        '<leader>at',
        function()
          require('sidekick.cli').send { msg = '{this}' }
        end,
        mode = { 'n', 'x' },
        desc = 'Send this',
      },
      {
        '<leader>af',
        function()
          require('sidekick.cli').send { msg = '{file}' }
        end,
        desc = 'Send file',
      },
      {
        '<leader>av',
        function()
          require('sidekick.cli').send { msg = '{selection}' }
        end,
        mode = { 'x' },
        desc = 'Send selection',
      },
      {
        '<leader>ap',
        function()
          require('sidekick.cli').prompt()
        end,
        mode = { 'n', 'x' },
        desc = 'Select prompt',
      },
    },
  },
}
