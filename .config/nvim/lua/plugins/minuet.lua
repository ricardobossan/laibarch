return {
  {
    "milanglacier/minuet-ai.nvim",
    commit = "7e696b717082e524286192ddaf397f709427f1a5",
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
}
