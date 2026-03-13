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
ls -la /etc/profiles/per-user/yarden/bin/

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

This config uses [sops-nix](https://github.com/Mic92/sops-nix) to manage secrets (e.g. git email). Secrets are encrypted with [age](https://github.com/FiloSottile/age) — each machine gets its own keypair, and `.sops.yaml` lists all the public keys that can decrypt. The private key (`~/.config/sops/age/keys.txt`) never leaves the machine it was generated on.

### 1. Generate an age key on the new machine

```bash
mkdir -p ~/.config/sops/age
nix shell nixpkgs#age -c age-keygen -o ~/.config/sops/age/keys.txt
```

Save the printed public key (`age1...`) — you'll need it in step 2.

**Back up `~/.config/sops/age/keys.txt` somewhere safe.** If you lose it, you can't decrypt the secrets from this machine.

### 2. Add the machine's public key to `.sops.yaml`

Each machine's public key needs to be listed in `.sops.yaml` so sops encrypts to all of them. Add the new key to the `keys` list, then re-encrypt from any machine that can already decrypt:

```bash
# Edit .sops.yaml to add the new key, then:
nix shell nixpkgs#sops -c sops updatekeys secrets/secrets.yaml
```

### 3. Rebuild

```bash
git add -A
sudo nixos-rebuild switch --flake .#wsl
```

### Removing a machine

To revoke a machine's access, remove its public key from `.sops.yaml` and run `sops updatekeys secrets/secrets.yaml`. The removed machine can no longer decrypt future versions of the secrets.

### Editing secrets

The `sops` alias is available in the shell — just run:

```bash
sops secrets/secrets.yaml
```

This opens the decrypted YAML in your editor. Save and close to re-encrypt.

## Structure

```
flake.nix              ← entry point
.sops.yaml             ← encryption rules (which age keys can decrypt)
secrets/secrets.yaml   ← encrypted secrets (committed as ciphertext)
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
