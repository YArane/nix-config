# NixOS Desktop Setup

Going from a fresh NixOS install (graphical installer, KDE Plasma) to this config.
Unlike WSL and macOS, there are no manual app installs: Chrome, Alacritty, IntelliJ,
FiraCode Nerd Font, Steam, GPU drivers and the keyboard remap are all declared in
`hosts/desktop/`.

## Before you start

- Install NixOS with the graphical installer. Tick **Allow unfree software**.
- The username is set in `hosts/desktop/default.nix` (the `username` variable).
  **Create the same user in the installer**, or change the variable to match. If they
  differ, the rebuild creates a new user with no password — you won't be able to log in.
- Plug in ethernet (or connect Wi-Fi in Plasma) — the first build downloads a lot.

## Steps

1. Clone the repo:
   ```bash
   nix --extra-experimental-features "nix-command flakes" shell nixpkgs#git --command \
     git clone https://github.com/YArane/nix-config.git ~/nix-config
   cd ~/nix-config
   ```

2. Bring in the machine-specific hardware config the installer generated (disk UUIDs,
   kernel modules, swap). It is specific to this machine, so it lives only in this host:
   ```bash
   cp /etc/nixos/hardware-configuration.nix hosts/desktop/
   git add hosts/desktop/hardware-configuration.nix
   ```

3. Glance at `/etc/nixos/configuration.nix` for anything the installer set that isn't
   in `hosts/desktop/default.nix` and that you want to keep (locale, keyboard layout).
   Also check `system.stateVersion` there — if it isn't `"26.05"`, use its value instead.

4. Build and switch (this moves the system from the 26.05 channel to the flake's
   nixpkgs-unstable pin; Home Manager runs as part of it):
   ```bash
   sudo nixos-rebuild switch --flake .#desktop
   ```
   Reboot once afterwards so keyd loads cleanly.

5. From now on:
   ```bash
   rebuild
   ```
   (runs `sudo nixos-rebuild switch --flake ~/nix-config#desktop`)

6. Set up an SSH key for GitHub (see [MACOS.md](MACOS.md#ssh-key-setup)), then switch
   the remote: `git remote set-url origin git@github.com:YArane/nix-config.git`.

`/etc/nixos/` is no longer used once you're on the flake. Leave it as a reference or
delete it.

## Things to know

### Graphics: RX 9070 XT

`hosts/desktop/amd.nix` covers the GPU. The amdgpu driver ships with the kernel and
Mesa comes with `hardware.graphics`, so there's no driver to pick or update separately.

### Gaming

Steam (with Proton-GE), GameMode, gamescope and MangoHud are in `hosts/desktop/gaming.nix`.
Per game, set Launch Options, e.g. `gamemoderun mangohud %command%`.
Install Steam games to a Linux-formatted drive (ext4/btrfs) — Proton is unreliable on NTFS.

### Keyboard

`hosts/desktop/keyboard.nix` remaps Scroll Lock → Left Super for the IBM Model M
(replaces SharpKeys).

### IntelliJ

Installed natively from nixpkgs (`jetbrains.idea`); it reads `~/.ideavimrc` directly.
Import settings from `~/nix-config/config/intellij/settings.zip`.

### Windows drives

Dolphin mounts them on click under `/run/media/$USER/`. Turn off Fast Startup in Windows
(`powercfg /h off`) or Linux will refuse to write to them.
