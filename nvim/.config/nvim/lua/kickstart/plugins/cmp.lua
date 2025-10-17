return {
  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    version = false,
    event = 'InsertEnter',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
      },
      'saadparwaiz1/cmp_luasnip',

      -- Adds other completion capabilities.
      --  nvim-cmp does not ship with all sources by default. They are split
      --  into multiple repos for maintenance purposes.
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
    config = function()
      -- See `:help cmp`
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup {}

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },

        -- Sorting configuration to prioritize fields and methods over snippets
        sorting = {
          priority_weight = 2,
          comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            -- Custom comparator to deprioritize snippets and prioritize fields/methods
            function(entry1, entry2)
              local kind1 = entry1:get_kind()
              local kind2 = entry2:get_kind()
              local types = require 'cmp.types'

              -- Check if entry is a snippet
              local function is_snippet(entry, kind)
                return kind == types.lsp.CompletionItemKind.Snippet or entry.source.name == 'luasnip'
              end

              local is_snippet1 = is_snippet(entry1, kind1)
              local is_snippet2 = is_snippet(entry2, kind2)

              -- Snippets should be last
              if is_snippet1 and not is_snippet2 then
                return false
              end
              if is_snippet2 and not is_snippet1 then
                return true
              end

              -- If both are snippets or both are not snippets, prioritize by kind
              -- Fields and properties first, then methods/functions
              local priority_kinds = {
                [types.lsp.CompletionItemKind.Field] = 1,
                [types.lsp.CompletionItemKind.Property] = 1,
                [types.lsp.CompletionItemKind.Method] = 2,
                [types.lsp.CompletionItemKind.Function] = 2,
              }

              local priority1 = priority_kinds[kind1] or 3
              local priority2 = priority_kinds[kind2] or 3

              if priority1 ~= priority2 then
                return priority1 < priority2
              end
            end,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            cmp.config.compare.locality,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
        },

        -- For an understanding of why these mappings were
        -- chosen, you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        mapping = cmp.mapping.preset.insert {
          -- Navigate completions
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),

          -- Browse documentation
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          -- Accept a completion
          ['<CR>'] = cmp.mapping.confirm { select = true },

          -- Manually trigger a completion from nvim-cmp.
          ['<C-Space>'] = cmp.mapping.complete {},

          -- Think of <c-l> as moving to the right of your snippet expansion.
          --  So if you have a snippet that's like:
          --  function $name($args)
          --    $body
          --  end
          --
          -- <c-l> will move you to the right of each of the expansion locations.
          -- <c-h> is similar, except moving you backwards.
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),

          -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        },
        sources = {
          {
            name = 'lazydev',
            -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
            group_index = 0,
          },
          { name = 'nvim_lsp', priority = 1000 },
          { name = 'path', priority = 500 },
          { name = 'luasnip', priority = 100 },
          { name = 'render-markdown', priority = 500 },
        },
      }
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
