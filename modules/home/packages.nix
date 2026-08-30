{ pkgs, ... }:

{
  home.packages = with pkgs; [
    jq      # JSON processor
    stern   # multi-pod/container log tailing for Kubernetes
    tree    # directory tree listing
    youplot # terminal plotting (uplot command)
  ];

  # bottom (btm) — system monitor with HM module
  programs.bottom.enable = true;
}
