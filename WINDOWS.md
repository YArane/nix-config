# Windows + WSL Setup

Everything needed to go from a fresh Windows machine to a working NixOS-WSL environment.

## Windows-side prerequisites

Install these on Windows before setting up WSL. They are native Windows apps — Nix can't manage them.

### Applications

- [Google Chrome](https://www.google.com/chrome/)
- [Alacritty](https://github.com/alacritty/alacritty/releases) — terminal emulator (config is managed by Nix, see below)
- [NixOS WSL](https://github.com/nix-community/NixOS-WSL/releases) — `nixos.wsl`

### Fonts

- [FiraCode Nerd Font](https://www.nerdfonts.com/font-downloads) — required for terminal icons and ligatures

### Graphics

- Update GPU drivers (NVIDIA/AMD/Intel)
- If external monitors aren't detected, check BIOS settings — ensure the display output is routed through the dedicated graphics card, not integrated graphics

### Keyboard

- [SharpKeys 3.9.6](https://github.com/randyrants/sharpkeys/releases) — remap Scroll Lock to Left Windows key
  - Map `Special: Scroll Lock (00_46)` → `Special: Left Windows (E0_5B)`
  - Needed for IBM Model M keyboards (1984) which lack a Windows key

## Fresh WSL install

### Before you start

The WSL username is set in `hosts/wsl/default.nix` (the `username` variable). Change it there before building if you want a different user.

### Steps

1. Install NixOS-WSL (double-click `nixos.wsl`), then open WSL.

2. Clone this repo:
   ```bash
   nix shell --extra-experimental-features "nix-command flakes" nixpkgs#git --command \
     git clone https://github.com/YArane/nix-config.git
   ```

3. Build and activate the config:
   ```bash
   cd nix-config
   sudo nixos-rebuild switch --flake .#wsl
   ```
   This creates the configured user and their home directory immediately.

4. Copy the repo to the new user's home:
   ```bash
   sudo cp -a ~/nix-config /home/yarden/nix-config
   sudo chown -R yarden:users /home/yarden/nix-config
   ```

5. Exit WSL, then restart it from PowerShell so it logs in as the new user:
   ```powershell
   wsl -t NixOS
   ```

6. Open WSL — you'll be logged in as the configured user. Clean up the old default user's home:
   ```bash
   sudo rm -rf /home/nixos
   ```

## Things to know

### Alacritty config is managed by Nix

Alacritty runs as a Windows app but its config is declared in `modules/home/terminal.nix`. On every rebuild, a Home Manager activation script automatically copies the generated `alacritty.toml` to `%APPDATA%\alacritty\` on the Windows side. You don't need to manage the Alacritty config file manually — just edit `terminal.nix` and rebuild.

### Username is set in one place

The WSL username, home directory, default shell, and Home Manager user are all derived from the `username` variable at the top of `hosts/wsl/default.nix`. To change your username, update it there before your first build.
