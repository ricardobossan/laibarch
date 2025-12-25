return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts_extend = { "spec" },
  opts = {
    preset = "helix",
    defaults = {},
    spec = {
      {
        mode = { "n", "v" },
        { "<leader>o", group = "obsidian" },
        { "<leader>c", group = "code" },
        { "<leader>D", group = "database" },
      },
    },
  },
}
