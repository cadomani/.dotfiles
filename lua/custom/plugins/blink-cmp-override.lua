-- Override blink-cmp to deprioritize snippets
-- Ports the nvim-cmp sorting logic: fields/methods before snippets
return {
  {
    'saghen/blink.cmp',
    opts = {
      -- Use enter to accept completions (like nvim-cmp default)
      keymap = {
        preset = 'enter',
        ['<C-y>'] = { 'select_and_accept' },
      },

      sources = {
        default = { 'lsp', 'path', 'snippets', 'lazydev' },
        providers = {
          -- Deprioritize snippets (lower score = appears later)
          snippets = { score_offset = -100 },
          -- Keep lazydev high priority for Neovim Lua development
          lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
        },
      },

      completion = {
        -- Show documentation automatically
        documentation = { auto_show = true, auto_show_delay_ms = 200 },

        -- Sort by kind to group similar items together
        menu = {
          draw = {
            -- Show completion item kind icons
            columns = { { 'kind_icon' }, { 'label', 'label_description', gap = 1 } },
          },
        },
      },
    },
  },
}
