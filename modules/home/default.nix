{ ... }:

{
  imports = [
    ./claude-code.nix
    ./git.nix
    ./packages.nix
    ./shell.nix
    ./ssh.nix
    ./terminal.nix
    ./tmux.nix
  ];

  home.stateVersion = "24.05";
}
