# Shared by every NixOS host (WSL + desktop).
#
# Each host declares its username once and hands it to this module with
# `_module.args.username = username;`. `_module.args` (unlike `specialArgs`)
# can't be used inside `imports = [...]`, but it's fine for config values like
# `users.users.${username}` below, which are evaluated lazily.
{ inputs, pkgs, username, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  # Provides a dynamic linker stub so Mason-downloaded binaries
  # (and other pre-built tools) can run on NixOS.
  programs.nix-ld.enable = true;

  programs.zsh.enable = true;

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = { inherit inputs; };
    # Hosts can append more modules via `home-manager.users.<name>.imports`;
    # lists from several modules are merged.
    users.${username}.imports = [ ../home ];
  };

  virtualisation.docker.enable = true;
}
