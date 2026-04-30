return {
  {
    "milanglacier/minuet-ai.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      provider = "claude",
      n_completions = 1,
      context_ratio = 0.5,
      provider_options = {
        claude = {
          model = "claude-haiku-4-5",
          max_tokens = 256,
          stream = true,
          api_key = "ANTHROPIC_API_KEY",
        },
      },
    },
    keys = {},
  },
  -- wire minuet into blink.cmp
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        default = {
          "lsp",
          "path",
          "snippets",
          "buffer" --[[, "minuet"]],
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
