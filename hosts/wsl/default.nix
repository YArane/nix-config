{ inputs, pkgs, ... }:

{
  wsl = {
    enable = true;
    defaultUser = "yarden";
  };

  networking.hostName = "nixos-wsl";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  security.pki.certificateFiles = [
    ./zscaler-root.pem
  ];

  programs.zsh.enable = true;

  users.users.yarden = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = { inherit inputs; };
    users.yarden = import ../../modules/home;
  };

  system.stateVersion = "24.05";
}
