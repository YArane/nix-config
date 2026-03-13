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

      # Gruvbox Dark (inlined — no separate theme file needed)
      colors = {
        primary = {
          background = "#000000";
          foreground = "#c7c7c7";
        };
        normal = {
          black   = "#282828";
          red     = "#cc241d";
          green   = "#98971a";
          yellow  = "#d79921";
          blue    = "#458588";
          magenta = "#b16286";
          cyan    = "#689d6a";
          white   = "#a89984";
        };
        bright = {
          black   = "#928374";
          red     = "#fb4934";
          green   = "#b8bb26";
          yellow  = "#fabd2f";
          blue    = "#83a598";
          magenta = "#d3869b";
          cyan    = "#8ec07c";
          white   = "#ebdbb2";
        };
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
