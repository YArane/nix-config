{ pkgs, ... }:

{
  home.packages = [
    # Not the nixpkgs derivation: the claude-code flake input's overlay
    # (registered in flake.nix) replaces it with a build that tracks upstream
    # releases hourly instead of lagging the nixpkgs-unstable channel.
    pkgs.claude-code

    # Claude Code shells out to `python3` (sometimes `python`) for ad-hoc
    # scripting; without an interpreter on PATH those calls just fail.
    # pkgs.python3 provides both binary names.
    pkgs.python3
  ];
}
