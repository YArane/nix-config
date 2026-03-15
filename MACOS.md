# macOS Setup

Everything needed to go from a fresh macOS machine to a working nix-darwin environment.

## Prerequisites

### Xcode Command Line Tools

```bash
xcode-select --install
```

Required for git and basic build tools before Nix is installed.

## Fresh install

### Before you start

The macOS username is set in `hosts/darwin/default.nix` (the `username` variable). It must match your macOS login username exactly — unlike WSL, the user already exists on macOS.

### Steps

1. Install Nix using the Determinate Systems installer:
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L \
     https://install.determinate.systems/nix | sh -s -- install
   ```
   This handles macOS-specific setup (creating the Nix APFS volume, configuring synthetic.conf, etc.) and enables flakes by default. Follow the prompts, then open a new terminal.

2. Clone this repo:
   ```bash
   git clone https://github.com/YArane/nix-config.git
   cd nix-config
   ```

3. Bootstrap nix-darwin (first run only — nix-darwin isn't installed yet, so use `nix run`):
   ```bash
   nix run nix-darwin -- switch --flake .#darwin
   ```
   This installs nix-darwin, applies the full system configuration, and installs Homebrew automatically. The first build will take a while.

4. After the first build, subsequent rebuilds use the alias:
   ```bash
   rebuild
   ```
   (This runs `darwin-rebuild switch --flake ~/nix-config#darwin`)

## Things to know

### Alacritty config is managed by Nix

Alacritty is installed via Homebrew cask, but its configuration is declared in `modules/home/terminal.nix`. Home Manager writes the config to `~/.config/alacritty/alacritty.toml` on every rebuild. Don't edit that file manually — change `terminal.nix` and rebuild.

### GUI apps use Homebrew casks

GUI applications (Chrome, Alacritty, etc.) are managed declaratively through nix-darwin's Homebrew integration in `hosts/darwin/default.nix`. The `onActivation.cleanup = "zap"` setting removes any cask not listed in the config. To add a new GUI app, add it to the `homebrew.casks` list and rebuild.

### Username must match your macOS login

The `username` variable in `hosts/darwin/default.nix` must match your macOS login username exactly. Unlike WSL where Nix creates the user, on macOS the user already exists.

### SSH key setup

Generate an SSH key for GitHub:
```bash
ssh-keygen -t ed25519 -C "your-email@example.com"
```
Then add `~/.ssh/id_ed25519.pub` to your GitHub account under Settings → SSH and GPG keys.
