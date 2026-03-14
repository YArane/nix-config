{ inputs, config, pkgs, ... }:

let
  username = "yarden";
in
{
  wsl = {
    enable = true;
    defaultUser = username;
  };

  networking.hostName = "nixos-wsl";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.keyFile = "/home/${username}/.config/sops/age/keys.txt";

    secrets = {
      "git-email" = { owner = username; };
    };

    templates."git-email-config" = {
      content = ''
        [user]
            email = ${config.sops.placeholder."git-email"}
      '';
      owner = username;
    };
  };

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
    users.${username} = import ../../modules/home;
  };

  system.stateVersion = "24.05";
}
