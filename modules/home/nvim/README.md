# Neovim — AstroNvim v5 on Nix

This neovim config uses AstroNvim v5 with lazy.nvim, managed through Nix Home Manager.
Updates are split across three layers — know which tool owns what.

## What lives where

| Component                  | Managed by       | Updated how                        |
|----------------------------|------------------|------------------------------------|
| Neovim binary              | Nix (nixpkgs)    | `flake.lock` update + rebuild      |
| System deps (gcc, rg, fd)  | Nix (Home Mgr)   | `flake.lock` update + rebuild      |
| AstroNvim + all plugins    | lazy.nvim        | `:Lazy update` inside neovim       |
| Treesitter parsers         | nvim-treesitter  | `:TSUpdate` inside neovim          |
| LSP servers, formatters    | Mason            | `:Mason` or `:MasonToolsUpdate`    |
| Config files (this dir)    | Nix (symlinks)   | Edit here, rebuild                 |

## Updating neovim itself

Neovim is pinned to whatever version is in your `flake.lock`'s nixpkgs. To update:

```bash
nix flake update             # bumps all inputs including nixpkgs
sudo nixos-rebuild switch --flake .#wsl
```

To update only nixpkgs without touching other inputs:

```bash
nix flake update nixpkgs-unstable
sudo nixos-rebuild switch --flake .#wsl
```

## Updating AstroNvim and plugins

AstroNvim and all plugins are managed by lazy.nvim at runtime, not by Nix.

```
:Lazy update          — update all plugins (including AstroNvim itself)
:Lazy sync            — install missing + update all + clean removed
:Lazy check           — check for updates without installing
:Lazy restore         — revert to versions in lazy-lock.json
```

The lock file lives at `~/.local/share/nvim/lazy-lock.json` (not in this directory)
because the config dir contains read-only Nix store symlinks.

> **Tip:** After a `:Lazy update`, open neovim again to verify nothing broke.
> AstroNvim pins itself to `^5` (semver), so major breaking changes won't sneak in.

## Updating treesitter parsers

Treesitter parsers are compiled binaries, separate from plugins:

```
:TSUpdate             — update all installed parsers
:TSUpdate lua nix     — update specific parsers
:TSInstall python     — install a new parser
:TSInstallInfo        — see installed/available parsers
```

Parsers are stored in `~/.local/share/nvim/` and compiled using the `gcc` provided
by `editor.nix`.

## Updating LSP servers, formatters, and linters

Mason manages these tool binaries independently from both Nix and lazy.nvim:

```
:Mason                — open Mason UI (browse, install, update, remove)
:MasonToolsUpdate     — update all tools in ensure_installed list
:LspInfo              — see which LSP servers are attached to current buffer
```

Mason downloads pre-built binaries into `~/.local/share/nvim/mason/`. The system
dependencies it needs (curl, wget, unzip, etc.) are provided by `editor.nix`.

> **Note:** Mason package names (hyphenated, e.g., `lua-language-server`) differ from
> lspconfig server names (underscored, e.g., `lua_ls`). Use `:Mason` to browse names.

## Adding a new language

The fastest path is an AstroCommunity pack. In `lua/community.lua`:

```lua
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.python" },   -- adds LSP, treesitter, etc.
}
```

Then rebuild and reopen neovim:

```bash
git add modules/home/nvim/lua/community.lua    # if file is new/untracked
sudo nixos-rebuild switch --flake .#wsl
```

Browse available packs: https://github.com/AstroNvim/astrocommunity

## Day-to-day workflow

1. **Edit config** — modify files in this directory (`modules/home/nvim/`)
2. **`git add`** — stage new files so Nix can see them
3. **Rebuild** — `sudo nixos-rebuild switch --flake .#wsl`
4. **Reopen neovim** — new config takes effect on next launch

## Useful neovim commands

| Command               | What it does                              |
|-----------------------|-------------------------------------------|
| `:Lazy`               | Plugin manager UI                         |
| `:Mason`              | LSP/tool installer UI                     |
| `:TSInstallInfo`      | Treesitter parser status                  |
| `:LspInfo`            | Active LSP servers for current buffer     |
| `:checkhealth`        | Diagnose issues (run this first if stuck) |
| `:AstroVersion`       | Show AstroNvim version                    |
