{ ... }:

{
  imports = [
    ./git.nix
    ./packages.nix
    ./ssh.nix
  ];

  home.stateVersion = "24.05";
}
