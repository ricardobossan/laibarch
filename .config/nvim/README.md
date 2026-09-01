# 💤 LazyVim Configuration

Personal Neovim configuration based on [LazyVim](https://github.com/LazyVim/LazyVim).

## Environment

- **Neovim Version**: 0.10.4
- **Rice**: [laibarch](https://github.com/ricar/laibarch) (Arch Linux setup)
- **Primary Languages**: C# (with Roslyn LSP), Markdown
- **Extensibility**: Mason, DAP, LSP, Treesitter

## Plugin Management

All plugins are **pinned to specific commits** to ensure compatibility with Neovim 0.10.4 and prevent breaking changes on fresh installs. A pin lives in the plugin's own spec file under `lua/plugins/`; plugins with no file of their own — mostly those LazyVim provides — are pinned in `lua/plugins/pins.lua`.

Pins are maintained by hand. `lazy.nvim` rewrites the working-copy `lazy-lock.json` on its own, so that file is not a trusted record: only commits captured by an actual `git commit` are.

### Updating Plugin Versions

When you want to update plugins to newer versions:

1. Update plugins: `:Lazy update` (pins hold, so raise or remove the specific `commit` you want to move first)
2. Test thoroughly to ensure everything works
3. Write the new commit into the plugin's spec file, or into `pins.lua` if it has none
4. Commit the change to lock the working version

To recover a known-good commit later, read it from a **committed** revision of `lazy-lock.json`:

```sh
git rev-list --all -- lazy-lock.json          # list revisions
git show <rev>:.config/nvim/lazy-lock.json    # read pins from one
```

This workflow ensures you control when plugins update and can always rollback to known-good versions.

## Key Features

- **C# Development**: Roslyn LSP, DAP debugging, easy-dotnet integration
- **Markdown**: Live preview, obsidian.nvim integration
- **AI Assistance**: Claude Code, Copilot
- **Custom Tweaks**: Catppuccin theme, diagflow, better-escape, transparency

## Installation

Refer to the [LazyVim documentation](https://lazyvim.github.io/installation) for setup basics.

After cloning this config:

1. Plugins will auto-install at pinned versions from their spec files and `pins.lua`
2. Mason LSP servers will auto-install (or run `:Mason` to manage manually)
3. No manual `:Lazy restore` needed - pins ensure correct versions
