# GTX 1050 Ti (Pascal).
#
# Pascal is no longer supported by NVIDIA's current driver, and the open kernel
# modules only support Turing (RTX 20 / GTX 16) and newer, so this uses the
# proprietary legacy 580 branch.
#
# When the AMD card goes in: delete this file and its line in default.nix.
# AMD's driver ships with the kernel, so nothing replaces it — optionally set
# `boot.kernelPackages = pkgs.linuxPackages_latest;` for the newest GPU support.
{ config, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics.enable = true;

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    open = false;
    modesetting.enable = true;
  };
}
