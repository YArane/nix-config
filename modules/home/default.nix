{ ... }:

{
  imports = [
    ./claude-code.nix
    ./git.nix
    ./packages.nix
    ./shell.nix
    ./ssh.nix
    ./terminal.nix
  ];

  home.stateVersion = "24.05";
}
