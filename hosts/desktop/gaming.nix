{ pkgs, username, ... }:

{
  programs.steam = {
    enable = true; # also turns on 32-bit graphics libraries
    # Proton-GE shows up in Steam → game Properties → Compatibility.
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  # Per-game: Launch Options → `gamemoderun %command%`
  programs.gamemode.enable = true;

  # Valve's micro-compositor (frame limiting, upscaling, HDR later on AMD).
  programs.gamescope.enable = true;

  # In-game FPS/frametime overlay: Launch Options → `mangohud %command%`
  environment.systemPackages = [ pkgs.mangohud ];

  users.users.${username}.extraGroups = [ "gamemode" ];
}
