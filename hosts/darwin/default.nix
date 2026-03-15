{ inputs, pkgs, ... }:

let
  username = "yarden";
in
{
  # ── Nix settings ──────────────────────────────────────────────────
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # ── System ────────────────────────────────────────────────────────
  networking.hostName = "yarden-mac";

  # nix-darwin manages /etc/zshenv so Nix-installed tools appear on PATH
  programs.zsh.enable = true;

  # ── User ──────────────────────────────────────────────────────────
  system.primaryUser = username;
  users.users.${username} = {
    home = "/Users/${username}";
  };

  # ── Home Manager ──────────────────────────────────────────────────
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = { inherit inputs; };
    users.${username} = import ../../modules/home;
  };

  # ── Homebrew (GUI apps) ──────────────────────────────────────────
  homebrew = {
    enable = true;
    casks = [
      "font-fira-code-nerd-font"
      "google-chrome"
      "alacritty"
    ];
    onActivation.cleanup = "zap";
  };

  # ── macOS defaults ───────────────────────────────────────────────
  system.defaults = {
    dock.autohide = false;
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain.AppleShowAllExtensions = true;
  };

  # Set once, never bumped (nix-darwin uses integers)
  system.stateVersion = 6;
}
