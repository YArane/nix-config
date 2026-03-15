{ pkgs, ... }:

{
  home.packages = with pkgs; [
    jq     # JSON processor
    tree   # directory tree listing
  ];

  # bottom (btm) — system monitor with HM module
  programs.bottom.enable = true;
}
