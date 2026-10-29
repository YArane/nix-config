# Jellyfin media server: http://localhost:8096 (or http://nixos-desktop:8096 on the LAN).
#
# Libraries are added in the web UI (not declarable): Movies → /mnt/a/Movies,
# Shows → /mnt/a/TV. Server state lives in /var/lib/jellyfin.
{ ... }:

{
  services.jellyfin = {
    enable = true;
    openFirewall = true; # 8096 (HTTP) + LAN discovery, so TVs/phones can find it

    # Transcode on the 9070 XT's media engine (VCN) instead of the CPU.
    # Only kicks in when a client can't direct-play (mostly remote viewers
    # capped by upload bandwidth).
    hardwareAcceleration = {
      enable = true;
      type = "vaapi";
      device = "/dev/dri/renderD128";
    };
    transcoding = {
      enableHardwareEncoding = true;
      # What RDNA 4's VCN can decode; VC-1 and VP8 fall back to the CPU.
      hardwareDecodingCodecs = {
        h264 = true;
        hevc = true;
        hevc10bit = true;
        vp9 = true;
        av1 = true;
      };
      hardwareEncodingCodecs = {
        hevc = true;
        av1 = true;
      }; # h264 is always on
    };
    # encoding.xml already exists from first run; without this the settings
    # above are ignored. Transcoding changes made in the web UI are reset on
    # every service restart; change them here instead.
    forceEncodingConfig = true;
  };

  # The render node is the GPU's compute/media interface (no display access).
  users.users.jellyfin.extraGroups = [ "render" ];
}
