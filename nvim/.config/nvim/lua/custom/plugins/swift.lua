-- Swift Language Support (macOS only)
if vim.fn.has 'mac' == 0 then
  return {}
end

return {
  -- Swift LSP Configuration
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'hrsh7th/cmp-nvim-lsp' },
    config = function()
      local lspconfig = require 'lspconfig'
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Configure sourcekit-lsp for Swift
      lspconfig.sourcekit.setup {
        capabilities = vim.tbl_deep_extend('force', capabilities, {
          workspace = {
            didChangeWatchedFiles = {
              dynamicRegistration = true,
            },
          },
        }),
        cmd = { 'xcrun', 'sourcekit-lsp' },
        filetypes = { 'swift' },
        root_dir = function(filename)
          -- First check for Xcode project/workspace files
          local xcode_project = lspconfig.util.root_pattern('*.xcodeproj', '*.xcworkspace')(filename)
          if xcode_project then
            return xcode_project
          end
          -- Fall back to Swift Package Manager or git
          return lspconfig.util.root_pattern('Package.swift', '.git')(filename) or lspconfig.util.path.dirname(filename)
        end,
        settings = {},
        -- Additional initialization for Xcode projects
        on_new_config = function(config, root_dir)
          -- Check if this is an Xcode project
          local xcode_project = vim.fn.glob(root_dir .. '/*.xcodeproj')
          local xcode_workspace = vim.fn.glob(root_dir .. '/*.xcworkspace')

          if xcode_project ~= '' or xcode_workspace ~= '' then
            -- Try to use xcode-build-server if available
            if vim.fn.executable 'xcode-build-server' == 1 then
              -- xcode-build-server will generate build information for sourcekit-lsp
              -- vim.notify('Xcode project detected. Using xcode-build-server for better module resolution.', vim.log.levels.INFO)
            else
              vim.notify(
                'Xcode project detected. Install xcode-build-server for better module resolution: brew install xcode-build-server',
                vim.log.levels.WARN
              )
            end
          end
        end,
      }
    end,
  },

  -- Swift Treesitter Support
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { 'swift' })
    end,
  },

  -- Swift-specific keymaps and autocommands
  {
    'neovim/nvim-lspconfig',
    init = function()
      -- Swift-specific autocommands
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'swift',
        callback = function()
          local opts = { buffer = true, silent = true }

          -- Detect project type and set appropriate build commands
          local root_dir = vim.fn.getcwd()
          local has_package_swift = vim.fn.filereadable(root_dir .. '/Package.swift') == 1
          local xcode_project = vim.fn.glob(root_dir .. '/*.xcodeproj')
          local xcode_workspace = vim.fn.glob(root_dir .. '/*.xcworkspace')

          if has_package_swift then
            -- Swift Package Manager commands
            vim.keymap.set('n', '<leader>sb', function()
              vim.cmd '!swift build'
            end, vim.tbl_extend('force', opts, { desc = 'Swift Build (SPM)' }))

            vim.keymap.set('n', '<leader>st', function()
              vim.cmd '!swift test'
            end, vim.tbl_extend('force', opts, { desc = 'Swift Test (SPM)' }))

            vim.keymap.set('n', '<leader>sr', function()
              vim.cmd '!swift run'
            end, vim.tbl_extend('force', opts, { desc = 'Swift Run (SPM)' }))
          elseif xcode_project ~= '' or xcode_workspace ~= '' then
            -- Xcode project commands
            local project_file = xcode_project ~= '' and xcode_project or xcode_workspace
            local project_name = vim.fn.fnamemodify(project_file, ':t:r')
            local project_flag = xcode_project ~= '' and '-project' or '-workspace'

            vim.keymap.set('n', '<leader>sb', function()
              local cmd = string.format(
                'cd %s && xcodebuild %s %s -scheme %s build',
                vim.fn.shellescape(root_dir),
                project_flag,
                vim.fn.shellescape(vim.fn.fnamemodify(project_file, ':t')),
                vim.fn.shellescape(project_name)
              )
              vim.cmd('!' .. cmd)
            end, vim.tbl_extend('force', opts, { desc = 'Xcode Build' }))

            vim.keymap.set('n', '<leader>st', function()
              local cmd = string.format(
                'cd %s && xcodebuild %s %s -scheme %s test',
                vim.fn.shellescape(root_dir),
                project_flag,
                vim.fn.shellescape(vim.fn.fnamemodify(project_file, ':t')),
                vim.fn.shellescape(project_name)
              )
              vim.cmd('!' .. cmd)
            end, vim.tbl_extend('force', opts, { desc = 'Xcode Test' }))

            vim.keymap.set('n', '<leader>sr', function()
              vim.notify('Use Xcode or iOS Simulator to run app. Building instead...', vim.log.levels.INFO)
              local cmd = string.format(
                'cd %s && xcodebuild %s %s -scheme %s build',
                vim.fn.shellescape(root_dir),
                project_flag,
                vim.fn.shellescape(vim.fn.fnamemodify(project_file, ':t')),
                vim.fn.shellescape(project_name)
              )
              vim.cmd('!' .. cmd)
            end, vim.tbl_extend('force', opts, { desc = 'Xcode Build (no run for iOS)' }))
          else
            -- Fallback for standalone Swift files
            vim.keymap.set('n', '<leader>sb', function()
              vim.cmd('!swiftc ' .. vim.fn.expand '%')
            end, vim.tbl_extend('force', opts, { desc = 'Compile Swift File' }))

            vim.keymap.set('n', '<leader>sr', function()
              vim.cmd('!swift ' .. vim.fn.expand '%')
            end, vim.tbl_extend('force', opts, { desc = 'Run Swift File' }))
          end

          -- Additional Xcode project specific keymaps

          if (xcode_project ~= '' or xcode_workspace ~= '') and vim.fn.executable 'xcode-build-server' == 1 then
            vim.keymap.set('n', '<leader>sbs', function()
              local project_file = xcode_project ~= '' and xcode_project or xcode_workspace
              local project_name = vim.fn.fnamemodify(project_file, ':t:r')
              local cmd = string.format(
                'cd %s && xcode-build-server config -project %s -scheme %s',
                vim.fn.shellescape(root_dir),
                vim.fn.shellescape(vim.fn.fnamemodify(project_file, ':t')),
                vim.fn.shellescape(project_name)
              )
              vim.cmd('!' .. cmd)
              vim.notify('Generated buildServer.json for Xcode project. Restart LSP with :LspRestart sourcekit', vim.log.levels.INFO)
            end, vim.tbl_extend('force', opts, { desc = 'Setup Xcode Build Server' }))

            vim.keymap.set('n', '<leader>sbl', function()
              local project_file = xcode_project ~= '' and xcode_project or xcode_workspace
              local cmd =
                string.format('cd %s && xcodebuild -list -project %s', vim.fn.shellescape(root_dir), vim.fn.shellescape(vim.fn.fnamemodify(project_file, ':t')))
              vim.cmd('!' .. cmd)
            end, vim.tbl_extend('force', opts, { desc = 'List Xcode Schemes' }))
          end

          -- Set Swift-specific options
          vim.opt_local.tabstop = 4
          vim.opt_local.shiftwidth = 4
          vim.opt_local.expandtab = true
          vim.opt_local.commentstring = '// %s'
        end,
      })
    end,
  },
}
