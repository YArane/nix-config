{
  description = "Java development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { nixpkgs, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      # Change JDK version here: jdk8, jdk11, jdk17, jdk21
      jdk = pkgs.jdk21;
    in
    {
      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = [
          jdk
          pkgs.maven
        ];

        env.JAVA_HOME = "${jdk}/lib/openjdk";
      };
    };
}
