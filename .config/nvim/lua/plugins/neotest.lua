return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "Issafalcon/neotest-dotnet",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-dotnet"),
        },
      })
    end,
  },

  -- Pin the adapter pulled in by lazyvim.plugins.extras.lang.python, which
  -- carries no commit of its own.
  {
    "nvim-neotest/neotest-python",
    commit = "e6df4f1892f6137f58135917db24d1655937d831",
  },
}
