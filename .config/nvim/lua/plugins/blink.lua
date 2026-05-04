return {
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        ghost_text = { enabled = false },
      },
      sources = {
        default = {
          "lsp",
          "path",
          "snippets",
          "buffer",
          -- "minuet", -- uncomment to add Claude completions to popup
        },
        providers = {
          minuet = {
            name = "minuet",
            module = "minuet.blink",
            async = true,
            timeout_ms = 8000,
            score_offset = 50,
          },
        },
      },
    },
  },
}
