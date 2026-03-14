{ lib, pkgs, config, ... }:

{
  programs.alacritty = {
    enable = true;
    package = null; # Alacritty is a Windows app on WSL

    settings = {
      env.TERM = "xterm-256color";

      general.working_directory = lib.mkIf pkgs.stdenv.isLinux
        "//wsl$/NixOS/home/${config.home.username}";

      window.dimensions = { columns = 160; lines = 48; };

      terminal = lib.mkIf pkgs.stdenv.isLinux {
        shell = {
          program = "C:\\\\Windows\\\\System32\\\\wsl.exe";
          args = [ "-d" "NixOS" ];
        };
      };

      scrolling.history = 100000;

      selection.save_to_clipboard = true;

      mouse.bindings = [
        { mouse = "Right"; action = "Paste"; }
      ];

      font = {
        normal = { family = "FiraCode Nerd Font"; style = "Regular"; };
        bold   = { family = "FiraCode Nerd Font"; style = "Bold"; };
        italic = { family = "FiraCode Nerd Font"; style = "Italic"; };
        size = 11.0;
      };

      # AstroTheme — astrodark palette
      colors = {
        primary = {
          background = "#1A1D23";
          foreground = "#9B9FA9";
        };
        normal = {
          black   = "#111317";
          red     = "#FF838B";
          green   = "#87C05F";
          yellow  = "#DFAB25";
          blue    = "#5EB7FF";
          magenta = "#DD97F1";
          cyan    = "#4AC2B8";
          white   = "#9B9FA9";
        };
        bright = {
          black   = "#696C76";  # used by zsh-autosuggestions (fg=8)
          red     = "#FFA6AE";
          green   = "#AAE382";
          yellow  = "#FFCE48";
          blue    = "#81DAFF";
          magenta = "#FFBAFF";
          cyan    = "#6DE5DB";
          white   = "#D0D3DE";
        };
        indexed_colors = [
          { index = 16; color = "#EB8332"; }
          { index = 17; color = "#F8747E"; }
        ];
      };
    };
  };

  # On WSL, Alacritty runs as a Windows app and reads config from
  # %APPDATA%\alacritty\. Copy the HM-generated config there on every rebuild.
  home.activation.copyAlacrittyToWindows = lib.mkIf pkgs.stdenv.isLinux (
    lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      win_user="$(/mnt/c/Windows/system32/cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')"
      if [ -z "$win_user" ]; then
        echo "WARNING: Could not detect Windows username; skipping Alacritty config copy"
      else
        alacritty_src="${config.xdg.configHome}/alacritty/alacritty.toml"
        alacritty_dst="/mnt/c/Users/$win_user/AppData/Roaming/alacritty/alacritty.toml"
        run mkdir -p "/mnt/c/Users/$win_user/AppData/Roaming/alacritty"
        run install -m 644 "$alacritty_src" "$alacritty_dst"
      fi
    ''
  );
}
