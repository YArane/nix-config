{ pkgs, ... }:

{
  home.packages = [
    pkgs.claude-code

    # Claude Code shells out to `python3` (sometimes `python`) for ad-hoc
    # scripting; without an interpreter on PATH those calls just fail.
    # pkgs.python3 provides both binary names.
    pkgs.python3
  ];
}
