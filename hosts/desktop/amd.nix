# Sapphire Nitro+ RX 9070 XT (RDNA 4).
#
# The amdgpu driver is part of the kernel and Mesa (RADV/radeonsi) comes with
# hardware.graphics, so there's no driver package to pick. RDNA 4 needs kernel
# 6.13+ and Mesa 25+, which nixpkgs-unstable's defaults already satisfy.
# Firmware comes from hardware.enableRedistributableFirmware (on via
# hardware-configuration.nix).
{ ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # 32-bit games (Steam also sets this)
  };

  # Load amdgpu in the initrd: native resolution from early boot, no flicker
  # when the display manager starts.
  hardware.amdgpu.initrd.enable = true;

  # GPU tuning (fan curve, power limit, undervolt) via the LACT GUI + lactd.
  # Settings made in the GUI are saved imperatively to /etc/lact/config.yaml.
  services.lact.enable = true;
  # Adds an amdgpu.ppfeaturemask kernel param (unlocks the OverDrive bit) so
  # LACT can change clocks/voltage.
  hardware.amdgpu.overdrive.enable = true;
}
