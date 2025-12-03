-- Conform.nvim override for prettier formatting
return {
  {
    'stevearc/conform.nvim',
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      -- JavaScript/TypeScript/React - use prettier (prefers project's node_modules version)
      opts.formatters_by_ft.javascript = { 'prettier' }
      opts.formatters_by_ft.javascriptreact = { 'prettier' }
      opts.formatters_by_ft.typescript = { 'prettier' }
      opts.formatters_by_ft.typescriptreact = { 'prettier' }
      opts.formatters_by_ft.vue = { 'prettier' }
      opts.formatters_by_ft.css = { 'prettier' }
      opts.formatters_by_ft.scss = { 'prettier' }
      opts.formatters_by_ft.less = { 'prettier' }
      opts.formatters_by_ft.html = { 'prettier' }
      opts.formatters_by_ft.json = { 'prettier' }
      opts.formatters_by_ft.jsonc = { 'prettier' }
      opts.formatters_by_ft.yaml = { 'prettier' }
      opts.formatters_by_ft.markdown = { 'prettier' }
      opts.formatters_by_ft.graphql = { 'prettier' }
      return opts
    end,
  },
}