return {
  'saecki/crates.nvim',
  event = { 'BufRead Cargo.toml' },
  config = function()
    require('crates').setup {
      popup = {
        autofocus = true,
        show_version_date = true,
      },
      lsp = {
        enabled = true,
        actions = true,
        completion = true,
        hover = true,
      },
    }
  end,
  -- stylua: ignore
  keys = {
    { '<leader>ci', function() require('crates').show_popup() end, desc = 'Show crate information', ft = 'toml' },
    { '<leader>cf', function() require('crates').show_features_popup() end, desc = 'Show crate features', ft = 'toml' },
    { '<leader>cv', function() require('crates').show_versions_popup() end, desc = 'Show crate versions', ft = 'toml' },
  },
}
