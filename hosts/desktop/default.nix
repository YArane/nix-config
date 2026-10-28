# Native NixOS desktop (custom-built tower; gaming + dev).
#
# Everything that's a manual install on the WSL/Windows side (Chrome, Alacritty,
# FiraCode Nerd Font, IntelliJ, GPU drivers, SharpKeys) is declared here instead.
{ pkgs, ... }:

let
  username = "yarden";
in
{
  imports = [
    ./hardware-configuration.nix # generated on the machine: copy from /etc/nixos/
    ../../modules/nixos/common.nix
    ./amd.nix
    ./gaming.nix
    ./foobar2000.nix
    ./keyboard.nix
  ];

  # Makes `username` available to the shared NixOS modules.
  _module.args.username = username;

  # ── Boot ──────────────────────────────────────────────────────────
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10; # keep the boot menu (and /boot) from filling up
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # Track the newest kernel: RDNA 4 still gets amdgpu fixes every release,
  # which the default LTS kernel only picks up much later.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ── System ────────────────────────────────────────────────────────
  networking.hostName = "nixos-desktop";
  networking.networkmanager.enable = true;

  # Onboard Bluetooth (wireless controllers, headsets); Plasma adds the tray UI.
  hardware.bluetooth.enable = true;

  time.timeZone = "America/Toronto";

  # Compressed swap in RAM; the disk swap partition is only used after this fills.
  zramSwap.enable = true;

  # Small (250GB) system drive: prune old generations weekly.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.optimise.automatic = true; # hard-link identical files in the store

  # ── Desktop ───────────────────────────────────────────────────────
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Audio via PipeWire (PulseAudio/ALSA/JACK clients all work).
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true; # 32-bit games
    pulse.enable = true;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code # Alacritty (replaces the manual Windows install)
    # Microsoft's web fonts, so sites that ask for them get the real thing
    # instead of Liberation/Noto look-alikes. Unfree (allowed in common.nix).
    corefonts   # Arial, Times New Roman, Verdana, Georgia, Tahoma, Courier New, …
    vista-fonts # Calibri, Cambria, Consolas, Candara, Constantia, Corbel
  ];

  # GUI apps that are manual Windows installs on the WSL host.
  # (Alacritty comes from modules/home/terminal.nix.)
  environment.systemPackages = with pkgs; [
    google-chrome
    jetbrains.idea # unified IntelliJ IDEA (the old Community edition is discontinued)
    klassy         # Plasma window decoration + application style (experiment)
  ];

  users.users.${username}.extraGroups = [ "networkmanager" ];

  # Set once at install time (the installer used 26.05) — never bump.
  system.stateVersion = "26.05";
}
