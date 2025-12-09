return {
  -- 'greggh/claude-code.nvim',
  -- dependencies = { 'nvim-lua/plenary.nvim' },
  -- config = function()
  --   require('claude-code').setup {
  --     -- Window settings
  --     window = {
  --       position = 'vertical',
  --     },
  --
  --     -- Command variants
  --     command_variants = {
  --       continue = '--continue',
  --       verbose = '--verbose',
  --       resume = '--resume',
  --     },
  --
  --     -- Keymaps
  --     keymaps = {
  --       toggle = {
  --         normal = '<C-,>', -- Normal mode keymap for toggling Claude Code
  --         terminal = '<C-,>', -- Terminal mode keymap for toggling Claude Code
  --         variants = {
  --           continue = '<leader>cC', -- Normal mode keymap for Claude Code with continue flag
  --           verbose = '<leader>cV', -- Normal mode keymap for Claude Code with verbose flag
  --           resume = '<leader>cR', -- Normal mode keymap for Claude Code with resume flag
  --         },
  --       },
  --     },
  --   }
  -- end,
  -- -- Load the plugin when these commands are used
  -- cmd = {
  --   'ClaudeCode',
  --   'ClaudeCodeContinue',
  --   'ClaudeCodeVerbose',
  --   'ClaudeCodeResume',
  -- },
  -- -- Load on these key mappings
  -- keys = {
  --   { '<C-,>', desc = 'Toggle Claude Code' },
  --   { '<leader>cC', desc = 'Continue Claude Code' },
  --   { '<leader>cV', desc = 'Claude Code Verbose' },
  --   { '<leader>cR', desc = 'Resume Claude Code' },
  -- },
  {
    'coder/claudecode.nvim',
    dependencies = { 'folke/snacks.nvim' },
    opts = {
      terminal_cmd = '~/.local/bin/claude',

      -- Send/Focus Behavior
      -- When true, successful sends will focus the Claude terminal if already connected
      focus_after_send = true,
    },
    config = true,
    keys = {
      { '<leader>a', nil, desc = 'AI/Claude Code' },
      { '<C-,>', '<cmd>ClaudeCode<cr>', mode = { 'n', 't' }, desc = 'Toggle Claude' },
      { '<leader>af', '<cmd>ClaudeCodeFocus<cr>', desc = 'Focus Claude' },
      { '<leader>ar', '<cmd>ClaudeCode --resume<cr>', desc = 'Resume Claude' },
      { '<leader>aC', '<cmd>ClaudeCode --continue<cr>', desc = 'Continue Claude' },
      { '<leader>am', '<cmd>ClaudeCodeSelectModel<cr>', desc = 'Select Claude model' },
      { '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', desc = 'Add current buffer' },
      { '<leader>as', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Send to Claude' },
      {
        '<leader>as',
        '<cmd>ClaudeCodeTreeAdd<cr>',
        desc = 'Add file',
        ft = { 'NvimTree', 'neo-tree', 'oil', 'minifiles' },
      },
      -- Diff management
      { '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', desc = 'Accept diff' },
      { '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', desc = 'Deny diff' },
    },
  },
}
