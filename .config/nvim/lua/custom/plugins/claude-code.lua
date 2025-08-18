return {
  'greggh/claude-code.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('claude-code').setup {
      -- Window settings
      window = {
        position = 'vertical',
      },

      -- Command variants
      command_variants = {
        continue = '--continue',
        verbose = '--verbose',
        resume = '--resume',
      },

      -- Keymaps
      keymaps = {
        toggle = {
          normal = '<C-,>', -- Normal mode keymap for toggling Claude Code
          terminal = '<C-,>', -- Terminal mode keymap for toggling Claude Code
          variants = {
            continue = '<leader>cC', -- Normal mode keymap for Claude Code with continue flag
            verbose = '<leader>cV', -- Normal mode keymap for Claude Code with verbose flag
            resume = '<leader>cR', -- Normal mode keymap for Claude Code with resume flag
          },
        },
      },
    }
  end,
  -- Load the plugin when these commands are used
  cmd = {
    'ClaudeCode',
    'ClaudeCodeContinue',
    'ClaudeCodeVerbose',
    'ClaudeCodeResume',
  },
  -- Load on these key mappings
  keys = {
    { '<C-,>', desc = 'Toggle Claude Code' },
    { '<leader>cC', desc = 'Continue Claude Code' },
    { '<leader>cV', desc = 'Claude Code Verbose' },
    { '<leader>cR', desc = 'Resume Claude Code' },
  },
}
