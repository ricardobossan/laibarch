-- Pin moved here from lua/plugins/pins.lua, which is only the fallback home for
-- plugins that have no spec file of their own.
return {
  "akinsho/bufferline.nvim",
  commit = "655133c3b4c3e5e05ec549b9f8cc2894ac6f51b3",
  -- LazyVim binds S-h / S-l to BufferLineCyclePrev/Next here (its own
  -- config/keymaps.lua binds them to bprevious/bnext -- that copy is deleted in
  -- lua/config/keymaps.lua). A `false` rhs drops the key from the resolved spec,
  -- restoring the builtin H / L motions. Buffer cycling stays on [b / ]b.
  keys = {
    { "<S-h>", false },
    { "<S-l>", false },
  },
}
