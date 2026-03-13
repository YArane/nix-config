{ inputs, config, pkgs, ... }:

{
  wsl = {
    enable = true;
    defaultUser = "yarden";
  };

  networking.hostName = "nixos-wsl";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.keyFile = "/home/yarden/.config/sops/age/keys.txt";

    secrets = {
      "git-email" = { owner = "yarden"; };
    };

    templates."git-email-config" = {
      content = ''
        [user]
            email = ${config.sops.placeholder."git-email"}
      '';
      owner = "yarden";
    };
  };

  security.pki.certificateFiles = [
    ./zscaler-root.pem
  ];

  # Provides a dynamic linker stub so Mason-downloaded binaries
  # (and other pre-built tools) can run on NixOS.
  programs.nix-ld.enable = true;

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
