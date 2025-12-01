return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          hidden = true, -- Show hidden files by default
          ignored = true, -- Show ignored files by default
        },
      },
    },
  },
  keys = {
    { "<leader>e", "<leader>fE", desc = "Explorer Snacks (cwd)", remap = true },
    { "<leader>E", "<leader>fe", desc = "Explorer Snacks (root dir)", remap = true },
  },
}
