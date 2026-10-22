{ ... }:

let
  username = "yarden";
in
{
  imports = [ ../../modules/nixos/common.nix ];

  # Makes `username` available to the shared NixOS modules.
  _module.args.username = username;

  wsl = {
    enable = true;
    defaultUser = username;
    interop.register = true; # re-register binfmt handler so .exe files work (e.g. powershell.exe for clipboard)
  };

  networking.hostName = "nixos-wsl";

  time.timeZone = "America/New_York";

  security.pki.certificateFiles = [
    ./zscaler-root.pem
  ];

  # Work cloud tooling — WSL only.
  home-manager.users.${username}.imports = [
    ../../modules/home/cloud.nix
  ];

  system.stateVersion = "24.05";
}
