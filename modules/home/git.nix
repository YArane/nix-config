{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "YArane";
    userEmail = "yarden.arane@gmail.com";

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
      side-by-side = true;
      # AstroTheme — astrodark palette
      minus-style                   = "syntax \"#392025\"";
      minus-non-emph-style          = "syntax \"#392025\"";
      minus-emph-style              = "syntax \"#4D2A30\"";
      minus-empty-line-marker-style = "syntax \"#392025\"";
      line-numbers-minus-style      = "red";
      plus-style                    = "syntax \"#1E2C18\"";
      plus-non-emph-style           = "syntax \"#1E2C18\"";
      plus-emph-style               = "syntax \"#2A3D20\"";
      plus-empty-line-marker-style  = "syntax \"#1E2C18\"";
      line-numbers-plus-style       = "green";
      line-numbers-zero-style       = "#1A1D23";
    };
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };
}
