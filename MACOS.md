# macOS Setup (Intel)

Everything needed to go from a fresh Intel Mac to a working nix-darwin environment.

> **Note:** Determinate Systems [dropped x86_64-darwin support](https://determinate.systems/blog/changelog-determinate-nix-3132/) in Determinate Nix 3.13.2, so this guide uses the official Nix installer instead.

## Prerequisites

### Xcode Command Line Tools

```bash
xcode-select --install
```

Required for git and basic build tools before Nix is installed.

## Fresh install

### Steps

1. Install Nix using the official installer:
   ```bash
   sh <(curl -L https://nixos.org/nix/install)
   ```
   Follow the prompts — the installer handles macOS-specific setup (creating the Nix APFS volume, configuring synthetic.conf, etc.). When it finishes, open a new terminal.

2. Install Homebrew (required by nix-darwin's `homebrew` module — Nix can't install it):
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

3. Clone this repo:
   ```bash
   git clone https://github.com/YArane/nix-config.git
   cd nix-config
   ```
> **Note:** The macOS username is set in `hosts/darwin/default.nix` (the `username` variable). It must match your macOS login username exactly — unlike WSL, the user already exists on macOS.

4. Back up shell files that nix-darwin needs to manage (one-time, on a fresh macOS):
   ```bash
   sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
   sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin
   ```
   nix-darwin writes its own versions of these to set up the Nix shell environment. It won't overwrite unrecognized files, so the originals must be moved first.

5. Bootstrap nix-darwin (first run only — nix-darwin isn't installed yet, so use `nix run`):
   ```bash
   sudo nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake .#darwin
   ```
   This installs nix-darwin and applies the full system configuration. The first build will take a while.

6. After the first build, subsequent rebuilds use the alias:
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
