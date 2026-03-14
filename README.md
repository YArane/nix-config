# nix-config

NixOS (WSL) and macOS configuration managed with Nix flakes and Home Manager.

## Quick Reference

### Rebuild after changes

```bash
# WSL
sudo nixos-rebuild switch --flake .#wsl

# macOS (when added)
darwin-rebuild switch --flake .#darwin
```

New files must be `git add`ed before rebuilding.

### Update packages

```bash
# Update all flake inputs (nixpkgs, home-manager, etc.)
nix flake update

# Update a single input
nix flake update nixpkgs

# Then rebuild to apply
sudo nixos-rebuild switch --flake .#wsl
```

### Search for packages

```bash
nix search nixpkgs <name>
```

### Try a package without installing

```bash
nix shell nixpkgs#<name>
```

### See what's installed

```bash
# Home Manager generation (includes package list)
ls -la /etc/profiles/per-user/$USER/bin/

# System packages
nix-store -q --requisites /run/current-system | grep -v '\.drv$'
```

### Check current system generation

```bash
nixos-rebuild list-generations
```

### Rollback

```bash
sudo nixos-rebuild switch --rollback
```

## Setting up on a new machine

### Fresh WSL install

1. Install [NixOS-WSL](https://github.com/nix-community/NixOS-WSL/releases) (double-click `nixos.wsl`)
2. Open WSL and clone this repo:
   ```bash
   nix shell --extra-experimental-features "nix-command flakes" nixpkgs#git --command \
     git clone https://github.com/YArane/nix-config.git
   ```
3. Build the config with `boot` (not `switch` — [required when changing the default user](https://github.com/nix-community/NixOS-WSL/blob/main/docs/src/how-to/change-username.md)):
   ```bash
   cd nix-config
   sudo nixos-rebuild boot --flake .#wsl
   ```
4. Copy the repo to the new user's home:
   ```bash
   sudo cp -a ~/nix-config /home/yarden/nix-config
   sudo chown -R yarden:users /home/yarden/nix-config
   ```
5. Exit WSL, then apply the new generation from PowerShell:
   ```powershell
   wsl -t NixOS
   wsl -d NixOS --user root exit
   wsl -t NixOS
   ```
6. Open WSL — you'll be logged in as the configured user. Finish setup:
   ```bash
   cd ~/nix-config
   sudo nixos-rebuild switch --flake .#wsl
   sudo userdel -r nixos
   ```
## Structure

```
flake.nix              ← entry point
hosts/wsl/             ← NixOS-WSL system config
modules/home/          ← Home Manager modules (shared across platforms)
  shell.nix            ← zsh, aliases
  git.nix              ← git + delta
  tmux.nix             ← tmux + sesh
  packages.nix         ← standalone CLI tools
  terminal.nix         ← alacritty
  ssh.nix              ← SSH config
  claude-code.nix      ← Claude Code settings
```

## Adding packages

**CLI tool you want everywhere** — add to `home.packages` in `modules/home/packages.nix`

**Tool with a Home Manager module** — use `programs.<tool>` in the appropriate module file

**Project-specific tooling** — use a `devShell` in `flake.nix`, not `home.packages`
