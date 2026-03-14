# Windows Setup

Software to install on the Windows side of a new WSL machine. These are outside Nix's reach — manage with winget, installers, or manual download.

## Applications

- [Google Chrome](https://www.google.com/chrome/)
- [Alacritty](https://github.com/alacritty/alacritty/releases) — terminal emulator
- [NixOS WSL](https://github.com/nix-community/NixOS-WSL/releases) — `nixos.wsl`

## Fonts

- [FiraCode Nerd Font](https://www.nerdfonts.com/font-downloads) — required for terminal icons and ligatures

## Graphics

- Update GPU drivers (NVIDIA/AMD/Intel)
- If external monitors aren't detected, check BIOS settings — ensure the display output is routed through the dedicated graphics card, not integrated graphics

## Keyboard

- [SharpKeys 3.9.6](https://github.com/randyrants/sharpkeys/releases) — remap Scroll Lock to Left Windows key
  - Map `Special: Scroll Lock (00_46)` → `Special: Left Windows (E0_5B)`
  - Needed for IBM Model M keyboards (1984) which lack a Windows key
