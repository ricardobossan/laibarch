return {
  "linux-cultist/venv-selector.nvim",
  commit = "42e8faadf9b819654f29eb1a785797a3a328f301",
  dependencies = {
    { "nvim-telescope/telescope.nvim", version = "*", dependencies = { "nvim-lua/plenary.nvim" } }, -- optional: you can also use fzf-lua, snacks, mini-pick instead.
  },
  ft = "python", -- Load when opening Python files
  keys = { { ",v", "<cmd>VenvSelect<cr>" } }, -- Open picker on keymap
  opts = {
    options = {}, -- plugin-wide options
    search = {}, -- custom search definitions
  },
}
