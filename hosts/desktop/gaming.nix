{ pkgs, username, ... }:

{
  programs.steam = {
    enable = true; # also turns on 32-bit graphics libraries
    # Proton-GE shows up in Steam → game Properties → Compatibility.
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  # Proton outside Steam (via umu-launcher), for Battle.net and other non-Steam
  # games. Its prefixes and downloaded Proton builds are mutable state in ~.
  environment.systemPackages = [ pkgs.faugus-launcher ];

  # Per-game: Launch Options → `gamemoderun %command%`
  programs.gamemode.enable = true;

  # Valve's micro-compositor (frame limiting, upscaling, HDR).
  programs.gamescope.enable = true;

  # In-game FPS/frametime overlay: Launch Options → `mangohud %command%`
  # Writes ~/.config/MangoHud/MangoHud.conf; the defaults (fps, frametime,
  # CPU/GPU load) stay on, these add sensors on top.
  home-manager.users.${username}.programs.mangohud = {
    enable = true;
    settings = {
      cpu_temp = true;
      cpu_power = true;
      gpu_temp = true;
      gpu_power = true;
    };
  };

  # cpu_power reads the RAPL energy counter, which the kernel makes root-only
  # (Platypus side-channel mitigation). Acceptable to expose on a single-user desktop.
  services.udev.extraRules = ''
    SUBSYSTEM=="powercap", KERNEL=="intel-rapl:0", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chmod 444 /sys%p/energy_uj"
  '';

  # Better Xbox controller driver over Bluetooth (rumble, correct button map).
  hardware.xpadneo.enable = true;

  users.users.${username}.extraGroups = [ "gamemode" ];
}
