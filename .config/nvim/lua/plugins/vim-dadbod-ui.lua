return {
  "kristijanhusak/vim-dadbod-ui",
  commit = "48c4f271da13d380592f4907e2d1d5558044e4e5",
  dependencies = {
    { "tpope/vim-dadbod", lazy = true },
    { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true }, -- Optional
  },
  cmd = {
    "DBUI",
    "DBUIToggle",
    "DBUIAddConnection",
    "DBUIFindBuffer",
  },
  init = function()
    -- Your DBUI configuration
    vim.g.db_ui_use_nerd_fonts = 1
    -- If you want unsecure ssl enabled, add `?ssl=0` at the end of the connection string
    vim.g.dbs = {}
  end,
}
