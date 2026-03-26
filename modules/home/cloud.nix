{ pkgs, ... }:

{
  home.packages = [
    pkgs.azure-cli
    pkgs.kubectl
    pkgs.kubelogin
  ];

  home.sessionVariables = {
    REQUESTS_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
  };
}
