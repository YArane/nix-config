# Jellyfin media server: http://localhost:8096 (or http://nixos-desktop:8096 on the LAN).
#
# Libraries are added in the web UI (not declarable): Movies → /mnt/a/Movies,
# Shows → /mnt/a/TV. Server state lives in /var/lib/jellyfin.
{ ... }:

{
  services.jellyfin = {
    enable = true;
    openFirewall = true; # 8096 (HTTP) + LAN discovery, so TVs/phones can find it
  };
}
