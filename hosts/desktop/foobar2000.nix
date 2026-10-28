# foobar2000 (Windows-only) under Wine, with the StrigUI theme, library and
# playlists carried over from Windows.
#
# Nix provides Wine and the launcher. The Wine prefix is mutable state; only two
# folders in it can't be regenerated (the program and the profile). A one-time
# copy of those lives on the music disk as a seed for setting up new machines;
# the launcher only ever reads it. The profile holds the Last.fm API secret, so
# it must never be copied into this repo.
#
# To refresh the seed after changing the theme or components (foobar2000 closed):
#   rsync -a --delete "<prefix>/drive_c/Program Files (x86)/foobar2000/" <seed>/program/
#   rsync -a --delete "<prefix>/drive_c/users/$USER/AppData/Roaming/foobar2000/" <seed>/profile/
#
# On first launch on a fresh machine the launcher rebuilds the prefix:
# Wine's system files from `wineboot`, the two folders from the seed, the DPI
# setting and the icon from this file.
{ config, pkgs, username, ... }:

let
  # On Windows the music lived at D:\simdisk\Music. Mapping D: to the same disk
  # keeps every library path and playlist entry valid without rewriting them.
  musicDrive = "/run/media/${username}/a";
  seed = "${musicDrive}/backups/foobar2000";

  prefix = "${config.users.users.${username}.home}/.local/share/wineprefixes/foobar2000";

  # 4K at Plasma's 145% scale: 96 × 1.45 ≈ 139.
  dpi = 139;

  foobar2000 = pkgs.writeShellApplication {
    name = "foobar2000";
    runtimeInputs = with pkgs; [ wineWow64Packages.stable udisks icoutils ];
    text = ''
      export WINEPREFIX="${prefix}"
      export WINEDEBUG=-all
      program="$WINEPREFIX/drive_c/Program Files (x86)/foobar2000"
      profile="$WINEPREFIX/drive_c/users/$USER/AppData/Roaming/foobar2000"

      # The music disk isn't mounted at boot yet; mount it by label on demand.
      [ -d "${musicDrive}/simdisk" ] || udisksctl mount -b /dev/disk/by-label/a

      # ── First run on a fresh machine: rebuild the prefix ──────────────
      if [ ! -d "$WINEPREFIX/drive_c" ]; then
        # Wine creates the prefix folder itself, but not its missing parents.
        mkdir -p "$WINEPREFIX"
        # Skip the Mono/Gecko install prompts while Wine creates the prefix.
        WINEDLLOVERRIDES="mscoree,mshtml=" wineboot -i
        wine reg add 'HKCU\Control Panel\Desktop' /v LogPixels /t REG_DWORD /d ${toString dpi} /f
        wineserver -w
      fi
      restore() { # restore <seed folder> <target>
        [ -d "$2" ] && return
        echo "Restoring $1 from ${seed}/$1"
        mkdir -p "$(dirname "$2")"
        cp -a "${seed}/$1" "$2"
      }
      restore program "$program"
      restore profile "$profile"
      if [ ! -f "$WINEPREFIX/foobar2000.png" ]; then
        tmp=$(mktemp -d)
        wrestool -x -t 14 "$program/foobar2000.exe" -o "$tmp"
        icotool -x -w 256 -o "$WINEPREFIX/foobar2000.png" "$tmp"/*.ico
        rm -r "$tmp"
      fi

      # Wine's mount manager hands D: to whatever USB stick is plugged in;
      # pin it to the music disk on every launch.
      rm -f "$WINEPREFIX/dosdevices/d::"
      ln -sfn "${musicDrive}" "$WINEPREFIX/dosdevices/d:"

      cd "$program"
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
    # Extracted from foobar2000.exe by the launcher on first run.
    icon = "${prefix}/foobar2000.png";
    categories = [ "AudioVideo" "Audio" "Player" ];
    # Wine sets each window's class to the .exe name; this lets Plasma match
    # the running window to this launcher (one taskbar entry, right icon).
    settings.StartupWMClass = "foobar2000.exe";
  };
}
