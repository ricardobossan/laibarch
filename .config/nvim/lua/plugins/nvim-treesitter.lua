return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "c_sharp",
      "lua",
      "markdown",
      "markdown_inline",
      "python",
      "javascript",
      "typescript",
      "rust",
      "go",
      "java",
    },
    -- Enable folding
    fold = {
      enable = true,
    },
  },
}
