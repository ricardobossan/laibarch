# 💤 LazyVim Configuration

Personal Neovim configuration based on [LazyVim](https://github.com/LazyVim/LazyVim).

## Environment

- **Neovim Version**: 0.10.4
- **Rice**: [laibarch](https://github.com/ricar/laibarch) (Arch Linux setup)
- **Primary Languages**: C# (with Roslyn LSP), Markdown
- **Extensibility**: Mason, DAP, LSP, Treesitter

## Plugin Management

All plugins are **pinned to specific commits** via `lua/plugins/lockfile-pins.lua` to ensure compatibility with Neovim 0.10.4 and prevent breaking changes on fresh installs.

### Updating Plugin Versions

When you want to update plugins to newer versions:

1. Remove the pins file: `rm lua/plugins/lockfile-pins.lua`
2. Update plugins: `:Lazy sync` (or `:Lazy update` for all)
3. Test thoroughly to ensure everything works
4. Regenerate pins: `nvim -l scripts/generate-lockfile-pins.lua`
5. Commit the new `lockfile-pins.lua` to lock the working versions

This workflow ensures you control when plugins update and can always rollback to known-good versions.

## Key Features

- **C# Development**: Roslyn LSP, DAP debugging, easy-dotnet integration
- **Markdown**: Live preview, obsidian.nvim integration
- **AI Assistance**: Claude Code, Copilot, Codeium
- **Custom Tweaks**: Catppuccin theme, diagflow, better-escape, transparency

## Installation

Refer to the [LazyVim documentation](https://lazyvim.github.io/installation) for setup basics.

After cloning this config:
1. Plugins will auto-install at pinned versions from `lockfile-pins.lua`
2. Mason LSP servers will auto-install (or run `:Mason` to manage manually)
3. No manual `:Lazy restore` needed - pins ensure correct versions
