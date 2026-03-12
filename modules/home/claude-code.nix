{ pkgs, ... }:

{
  home.packages = [ pkgs.claude-code ];

  home.file.".claude/settings.json".text = builtins.toJSON {
    enabledPlugins = {
      "commit-commands@claude-plugins-official" = true;
    };
  };
}
