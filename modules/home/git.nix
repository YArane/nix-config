{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings.user = {
      name = "YArane";
      email = "yarden.arane@gmail.com";
    };
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };
}
