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

  # NT sync primitives in the kernel; Proton-GE / Wine 10+ use /dev/ntsync
  # when present (replaces esync/fsync). Built as a module, so load it at boot.
  boot.kernelModules = [ "ntsync" ];

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
      gpu_core_clock = true;
      gpu_mem_clock = true;
      gpu_junction_temp = true;
      gpu_mem_temp = true;
      present_mode = true; # mode the game requests; MESA_VK_WSI_PRESENT_MODE overrides don't show here

      # Benchmark logging: Shift+F2 starts a log, which stops itself after
      # log_duration seconds. Each run writes a per-frame CSV plus a
      # *_summary.csv (avg FPS, 1%/0.1% lows) to output_folder.
      output_folder = "/home/${username}/mangohud-logs";
      log_duration = 300;
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
