return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = function(_, opts)
      -- Force compilation from source instead of downloading pre-built parsers
      -- This prevents issues when pre-built tarballs are corrupted or unavailable
      require("nvim-treesitter.install").prefer_git = true
      return opts
    end,
  },
}
