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
  keys = {
    { "<leader>D", "", desc = "+database", remap = true },
    { "<leader>Du", "<cmd>DBUIToggle<CR>", desc = "Toggle UI", remap = true },
    { "<leader>Da", "<cmd>DBUIAddConnection<CR>", desc = "Add Connection", remap = true },
    { "<leader>Df", "<cmd>DBUIFindBuffer<CR>", desc = "Find Buffer", remap = true },
    { "<leader>Do", "<cmd>DBUI<CR>", desc = "Open UI", remap = true },
    { "<leader>Dr", "<cmd>normal vip<CR><PLUG>(DBUI_ExecuteQuery)", desc = "Run Query", remap = true, mode = "n" },
    { "<leader>Dr", "<PLUG>(DBUI_ExecuteQuery)", desc = "Run Query", remap = true, mode = "v" },
    { "<leader>Dw", "<cmd>DBUILastQueryInfo<CR>", desc = "Last Query Info", remap = true },
  },
  init = function()
    -- Your DBUI configuration
    vim.g.db_ui_use_nerd_fonts = 1
    -- If you want unsecure ssl enabled, add `?ssl=0` at the end of the connection string
    vim.g.dbs = {}

    -- Custom keymaps for SQL buffers
    vim.g.db_ui_execute_on_save = 1
  end,
}
