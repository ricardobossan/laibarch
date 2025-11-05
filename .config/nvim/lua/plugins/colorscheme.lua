return {

  -- tokyonight
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = { style = "moon" },
  },

  -- catppuccin
  {
    "catppuccin/nvim",
    branch = "main",
    -- Locked due to breaking changes in later commit
    commit = "5b5e3aef9ad7af84f463d17b5479f06b87d5c429",
    name = "catppuccin",
    priority = 1000,
    dependencies = {
      "",
    },
    {
      "LazyVim/LazyVim",
      opts = {
        colorscheme = "catppuccin-mocha",
      },
    },
    opts = function(_, opts)
      if (vim.g.colors_name or ""):find("catppuccin") then
        opts.highlights = require("catppuccin.groups.integrations.bufferline").get()
      end
    end,
  },
}
