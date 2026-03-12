{ inputs, pkgs, ... }:

{
  wsl = {
    enable = true;
    defaultUser = "nixos";
  };

  networking.hostName = "nixos-wsl";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  security.pki.certificateFiles = [
    ./zscaler-root.pem
  ];

  programs.zsh.enable = true;

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = { inherit inputs; };
    users.nixos = import ../../modules/home;
  };

  system.stateVersion = "24.05";
}
