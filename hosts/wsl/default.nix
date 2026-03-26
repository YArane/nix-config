{ inputs, pkgs, ... }:

let
  username = "yarden";
in
{
  wsl = {
    enable = true;
    defaultUser = username;
    interop.register = true; # re-register binfmt handler so .exe files work (e.g. powershell.exe for clipboard)
  };

  networking.hostName = "nixos-wsl";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  security.pki.certificateFiles = [
    ./zscaler-root.pem
  ];

  # Provides a dynamic linker stub so Mason-downloaded binaries
  # (and other pre-built tools) can run on NixOS.
  programs.nix-ld.enable = true;

  programs.zsh.enable = true;

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = { inherit inputs; };
    users.${username} = {
      imports = [
        ../../modules/home
        ../../modules/home/cloud.nix
      ];
    };
  };

  system.stateVersion = "24.05";
}
