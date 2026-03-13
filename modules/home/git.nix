{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings.user = {
      name = "YArane";
      email = "yarden.arane@gmail.com";
    };

    settings = {
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      light = false;
      theme = "Github";
      side-by-side = true;
    };
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };
}
