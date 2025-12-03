-- TypeScript/JavaScript configuration
-- Uses vtsls (VSCode TypeScript extension wrapper) and ESLint LSP
return {
  {
    'neovim/nvim-lspconfig',
    init = function()
      -- vtsls configuration (TypeScript/JavaScript)
      vim.lsp.config('vtsls', {
        filetypes = {
          'javascript',
          'javascriptreact',
          'javascript.jsx',
          'typescript',
          'typescriptreact',
          'typescript.tsx',
        },
        settings = {
          complete_function_calls = true,
          vtsls = {
            enableMoveToFileCodeAction = true,
            autoUseWorkspaceTsdk = true,
            experimental = {
              maxInlayHintLength = 30,
              completion = {
                enableServerSideFuzzyMatch = true,
              },
            },
          },
          typescript = {
            updateImportsOnFileMove = { enabled = 'always' },
            suggest = {
              completeFunctionCalls = true,
            },
            inlayHints = {
              enumMemberValues = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              parameterNames = { enabled = 'literals' },
              parameterTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              variableTypes = { enabled = false },
            },
          },
        },
      })
      vim.lsp.enable 'vtsls'

      -- ESLint LSP configuration
      vim.lsp.config('eslint', {
        settings = {
          workingDirectories = { mode = 'auto' },
        },
      })
      vim.lsp.enable 'eslint'

      -- TypeScript-specific keymaps on LspAttach
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('typescript-lsp-attach', { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if not client or client.name ~= 'vtsls' then
            return
          end

          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gD', function()
            local params = vim.lsp.util.make_position_params()
            vim.lsp.buf.execute_command {
              command = 'typescript.goToSourceDefinition',
              arguments = { params.textDocument.uri, params.position },
            }
          end, 'Goto Source Definition')

          map('<leader>co', function()
            vim.lsp.buf.code_action {
              apply = true,
              context = {
                only = { 'source.organizeImports' },
                diagnostics = {},
              },
            }
          end, 'Organize Imports')

          map('<leader>cM', function()
            vim.lsp.buf.code_action {
              apply = true,
              context = {
                only = { 'source.addMissingImports.ts' },
                diagnostics = {},
              },
            }
          end, 'Add Missing Imports')

          map('<leader>cu', function()
            vim.lsp.buf.code_action {
              apply = true,
              context = {
                only = { 'source.removeUnused.ts' },
                diagnostics = {},
              },
            }
          end, 'Remove Unused Imports')

          map('<leader>cD', function()
            vim.lsp.buf.code_action {
              apply = true,
              context = {
                only = { 'source.fixAll.ts' },
                diagnostics = {},
              },
            }
          end, 'Fix All Diagnostics')
        end,
      })
    end,
  },
}