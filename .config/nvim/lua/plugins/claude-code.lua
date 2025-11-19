return {
  "greggh/claude-code.nvim",
  commit = "c9a31e51069977edaad9560473b5d031fcc5d38b",
  dependencies = {
    "nvim-lua/plenary.nvim", -- Required for git operations
  },
  config = function()
    require("claude-code").setup()
  end,
}
