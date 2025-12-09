return {
  {
    "seblyng/roslyn.nvim",
    ft = "cs",
    ---@module 'roslyn.config'
    ---@type RoslynNvimConfig
    opts = {
      require("mason").setup({
        registries = {
          "github:mason-org/mason-registry",
          "github:Crashdummyy/mason-registry",
        },
      }),
    },
  },

  -- Ensure roslynv4 is installed
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        --"roslynv4",
      },
    },
  },
}
