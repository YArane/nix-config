# Sapphire Nitro+ RX 9070 XT (RDNA 4) and its tuning, plus notes on the
# Ryzen 7 9800X3D's BIOS tuning at the bottom.
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

  # GPU tuning (power limit, undervolt, VRAM clock) applied by lactd at boot.
  # With `settings` set, /etc/lact/config.yaml is a read-only store symlink:
  # the LACT GUI can still try values live, but changes only stick here.
  #
  # Tested 2026-10-29 in Superposition 4K Optimized (stock = 19574):
  #   -90 mV,  330 W, VRAM 2700  → 20844 (+6.5%, same power as stock)  ← daily
  #   -90 mV,  374 W, VRAM 2700  → 21291 (+8.8%, +13% power, louder fans)
  #   -140 mV, 330 W, VRAM 2826  → 21463 (+9.6%; one run, stability unproven)
  #   -140 mV, 374 W, VRAM 2826  → 21897 (+11.9%)
  # Instability shows as `ring gfx timeout` / GPU reset in `journalctl -k`;
  # pageflip/flip_done timeouts were the display path (HDR toggling), not this.
  services.lact = {
    enable = true;
    settings = {
      version = 6;
      daemon = {
        log_level = "info";
        admin_group = "wheel";
        disable_clocks_cleanup = false;
      };
      apply_settings_timer = 5;
      gpus."1002:7550-1DA2:E489-0000:03:00.0" = {
        fan_control_enabled = false; # stock fan curve
        pmfw_options.zero_rpm = true; # fans stop at idle
        power_cap = 330.0; # watts; stock 330, max 374
        performance_level = "auto";
        max_memory_clock = 1350; # kernel units (half of the 2700 LACT shows; stock 1258)
        voltage_offset = -90; # mV
      };
      current_profile = null;
      auto_switch_profiles = false;
    };
  };
  # Adds an amdgpu.ppfeaturemask kernel param (unlocks the OverDrive bit) so
  # LACT can change clocks/voltage.
  hardware.amdgpu.overdrive.enable = true;

  # ── CPU: Ryzen 7 9800X3D — tuned in the BIOS, not Nix ─────────────
  # MSI PRO B850-V EVO WIFI, BIOS 4.A43. Re-enter these after a BIOS update
  # (it resets them). Path: OC → Advanced CPU Configuration → AMD Overclocking
  # → Precision Boost Overdrive.
  #   PBO                          Advanced
  #   PBO Limits                   Motherboard
  #   Curve Optimizer              All Cores, Negative, 35
  #   Max CPU Boost Clock Override +200 MHz  (cpuinfo_max_freq → 5455 MHz)
  # Unstable CO shows as silent freezes/reboots at idle or light load, or MCE
  # lines in `journalctl -k -b -1`. Fallback: -30, then -25.
}
