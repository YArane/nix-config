{ lib, pkgs, config, ... }:

let
  # Windows APPDATA path as seen from WSL (for syncing Alacritty config).
  # NOTE: This username is machine-specific — update if your Windows username differs.
  windowsAppData = "/mnt/c/Users/Yarden.Arane/AppData/Roaming";
in
{
  programs.alacritty = {
    enable = true;
    package = null; # Alacritty is a Windows app on WSL

    settings = {
      env.TERM = "xterm-256color";

      general.working_directory = lib.mkIf pkgs.stdenv.isLinux
        "//wsl$/NixOS/home/yarden";

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
      alacritty_src="${config.xdg.configHome}/alacritty/alacritty.toml"
      alacritty_dst="${windowsAppData}/alacritty/alacritty.toml"
      run mkdir -p "${windowsAppData}/alacritty"
      run install -m 644 "$alacritty_src" "$alacritty_dst"
    ''
  );
}
