# foobar2000 (Windows-only) under Wine, with the StrigUI theme, library and
# playlists carried over from Windows.
#
# Nix provides Wine and the launcher; the Wine prefix itself is mutable state in
# ~/.local/share/wineprefixes/foobar2000 (it holds the foobar2000 profile,
# including the Last.fm API secret, so it must never be copied into this repo).
{ config, pkgs, username, ... }:

let
  # On Windows the music lived at D:\simdisk\Music. Mapping D: to the same disk
  # keeps every library path and playlist entry valid without rewriting them.
  musicDrive = "/run/media/${username}/a";

  prefix = "${config.users.users.${username}.home}/.local/share/wineprefixes/foobar2000";

  foobar2000 = pkgs.writeShellApplication {
    name = "foobar2000";
    runtimeInputs = [ pkgs.wineWow64Packages.stable pkgs.udisks ];
    text = ''
      export WINEPREFIX="${prefix}"
      export WINEDEBUG=-all

      # The music disk isn't mounted at boot yet; mount it by label on demand.
      [ -d "${musicDrive}/simdisk" ] || udisksctl mount -b /dev/disk/by-label/a

      # Wine's mount manager hands D: to whatever USB stick is plugged in;
      # pin it to the music disk on every launch.
      rm -f "$WINEPREFIX/dosdevices/d::"
      ln -sfn "${musicDrive}" "$WINEPREFIX/dosdevices/d:"

      cd "$WINEPREFIX/drive_c/Program Files (x86)/foobar2000"
      exec wine foobar2000.exe
    '';
  };
in
{
  environment.systemPackages = [ foobar2000 ];

  home-manager.users.${username}.xdg.desktopEntries.foobar2000 = {
    name = "foobar2000";
    genericName = "Music Player";
    exec = "foobar2000";
    # Extracted once from foobar2000.exe into the prefix (icoutils); like the
    # rest of the prefix it's state, not something Nix builds.
    icon = "${prefix}/foobar2000.png";
    categories = [ "AudioVideo" "Audio" "Player" ];
    # Wine sets each window's class to the .exe name; this lets Plasma match
    # the running window to this launcher (one taskbar entry, right icon).
    settings.StartupWMClass = "foobar2000.exe";
  };
}
