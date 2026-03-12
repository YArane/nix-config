{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  home.packages = [ ];
}
