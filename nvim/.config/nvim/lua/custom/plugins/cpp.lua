return {
  {
    -- C++ specific configuration
    'p00f/clangd_extensions.nvim',
    lazy = true,
    ft = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
    dependencies = {
      'neovim/nvim-lspconfig',
      'hrsh7th/cmp-nvim-lsp',
      -- Add nvim-lint as dependency to ensure it's installed
      'mfussenegger/nvim-lint',
    },
    config = function()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Make sure clangd uses the same capabilities as other LSP servers
      local clangd_capabilities = vim.deepcopy(capabilities)

      -- Disable offset encoding in clangd since it causes issues
      ---@diagnostic disable-next-line: inject-field
      clangd_capabilities.offsetEncoding = { 'utf-16' }

      -- Configure and start clangd directly with lspconfig
      -- This ensures it gets registered properly
      require('lspconfig').clangd.setup {
        cmd = {
          'clangd',
          '--background-index',
          '--clang-tidy',
          '--header-insertion=iwyu',
          '--completion-style=detailed',
          '--function-arg-placeholders',
          '--fallback-style=llvm',
        },
        capabilities = clangd_capabilities,
        on_attach = function(client, bufnr)
          -- Override hover to use the enhanced hover
          vim.keymap.set('n', 'K', function()
            vim.lsp.buf.hover()
          end, { buffer = bufnr })

          -- Setup switch between header/source
          vim.keymap.set('n', '<leader>ch', '<cmd>ClangdSwitchSourceHeader<cr>', { buffer = bufnr, desc = 'Switch Header/Source' })

          -- Add common LSP keymaps
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = bufnr, desc = 'Go to Definition' })
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { buffer = bufnr, desc = 'Go to Implementation' })
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, { buffer = bufnr, desc = 'Find References' })

          -- Enable inlay hints if available
          if client.server_capabilities.inlayHintProvider and vim.fn.has 'nvim-0.10' == 1 then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          end
        end,
      }

      -- Now setup clangd_extensions once we know clangd is properly registered
      require('clangd_extensions').setup {
        server = {}, -- Server options are handled above
        extensions = {
          -- Automatically set inlay hints
          inlay_hints = {
            inline = vim.fn.has 'nvim-0.10' == 1,
            only_current_line = false,
            show_parameter_hints = true,
            parameter_hints_prefix = '<- ',
            other_hints_prefix = '=> ',
            max_len_align = false,
            max_len_align_padding = 1,
            right_align = false,
            right_align_padding = 7,
            highlight = 'Comment',
            priority = 100,
          },
          ast = {
            role_icons = {
              type = '🄣',
              declaration = '🄓',
              expression = '🄔',
              statement = ';',
              specifier = '🄢',
              ['template argument'] = '🆃',
            },
            kind_icons = {
              Compound = '🄲',
              Recovery = '🅁',
              TranslationUnit = '🅄',
              PackExpansion = '🄿',
              TemplateTypeParm = '🅃',
              TemplateTemplateParm = '🅃',
              TemplateParamObject = '🅃',
            },
            highlights = {
              detail = 'Comment',
            },
          },
          memory_usage = {
            border = 'none',
          },
          symbol_info = {
            border = 'none',
          },
        },
      }

      -- Set up cpplint (defer until nvim-lint is loaded)
      vim.schedule(function()
        local ok, lint = pcall(require, 'nvim-lint')
        if ok then
          -- Configure linters
          lint.linters_by_ft = lint.linters_by_ft or {}
          lint.linters_by_ft.cpp = { 'cpplint' }
          lint.linters_by_ft.c = { 'cpplint' }

          -- Customize cpplint configuration if available
          if lint.linters and lint.linters.cpplint then
            lint.linters.cpplint.args = {
              '--filter=-legal/copyright,-build/include_subdir',
              '--linelength=120',
            }
          end

          -- Create autocommand which carries out the actual linting
          vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
            group = vim.api.nvim_create_augroup('cpp_lint', { clear = true }),
            callback = function()
              -- Only run the linter in buffers that you can modify
              if vim.bo.modifiable and (vim.bo.filetype == 'cpp' or vim.bo.filetype == 'c') then
                lint.try_lint()
              end
            end,
          })
        end
      end)
    end,
  },
  -- {
  --   -- Add formatting support for C/C++
  --   'stevearc/conform.nvim',
  --   optional = true,
  --   opts = {
  --     formatters_by_ft = {
  --       cpp = { 'clang-format' },
  --       c = { 'clang-format' },
  --     },
  --   },
  -- },
}
