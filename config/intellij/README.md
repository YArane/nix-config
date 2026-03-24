# IntelliJ IDEA Settings

Curated IntelliJ settings, stripped of machine-specific paths, plugin state, and bloat.

## How to import

1. Open IntelliJ IDEA on Windows
2. File → Manage IDE Settings → Import Settings
3. Browse to `\\wsl$\NixOS\home\yarden\nix-config\config\intellij\settings.zip`
4. Check all categories and import

## What's included

- **Theme**: Stock Darcula, FiraCode Nerd Font size 15 (set line spacing to 1.2 manually after import)
- **IdeaVim**: Enabled with key-repeat and resolved shortcut conflicts (Vim wins all except Ctrl+H)
- **Code style**: Java wildcard imports disabled (explicit imports only)
- **Editor**: Code vision on the right, Java + SQL inlay hints, rendered Javadoc
- **Debugger**: Step filters for JDK internals, testing frameworks, and common libraries
- **Keymaps**: Visual Studio (Windows + macOS) with GotoImplementation on Alt+End
- **Advanced**: 20 recent/temporary run configuration slots

## What's NOT included

- **JDK paths** — IntelliJ auto-detects JDKs. Use the Nix devShell (`nix flake init -t ~/nix-config#java`) for project JDKs.
- **Plugins** — Install fresh per machine. Previously used: IdeaVIM, SpotBugs, PMD, Palantir Java Format, JProfiler.
- **Window layout** — Machine-specific, not portable.
- **Database connections** — Configure per environment.

## WSL setup

IntelliJ runs on Windows and connects to the WSL filesystem:

1. Install IntelliJ on Windows (winget, JetBrains Toolbox, or manual)
2. Open projects from `\\wsl$\NixOS\home\yarden\...`
3. Configure Project SDK to use the WSL JDK (detected automatically from devShell)
4. Set terminal to WSL: Settings → Tools → Terminal → Shell path: `wsl.exe`
