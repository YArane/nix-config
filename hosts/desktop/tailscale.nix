# Tailscale: private WireGuard mesh for reaching services (Jellyfin, ...) away
# from home without port forwarding. Reachable as nixos-desktop.<tailnet>.ts.net.
#
# One-time login after the first rebuild: `sudo tailscale up` (opens a browser
# URL). State lives in /var/lib/tailscale. An authKeyFile would make this
# unattended, but needs sops-nix first.
#
# Who can reach which port is set in the Tailscale admin console (machine
# sharing + access policy), not here. Shared friends should only get :8096.
{ ... }:

{
  services.tailscale = {
    enable = true;
    openFirewall = true; # UDP 41641, so peers connect directly instead of via relays
  };
}
