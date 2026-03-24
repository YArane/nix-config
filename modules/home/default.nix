{ ... }:

{
  imports = [
    ./claude-code.nix
    ./editor.nix
    ./git.nix
    ./ideavim.nix
    ./packages.nix
    ./shell.nix
    ./ssh.nix
    ./terminal.nix
    ./tmux.nix
  ];

  home.stateVersion = "24.05";
}
