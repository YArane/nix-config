{
  description = "NixOS configuration for WSL and macOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixpkgs pins the Claude Code version in an in-tree manifest, so we only
    # get whatever version the nixpkgs-unstable channel snapshot happened to
    # capture — usually days behind. This flake polls Anthropic's release CDN
    # hourly and pins the sha256, so `nix flake update` tracks the real latest.
    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { nixpkgs, home-manager, nixos-wsl, nix-darwin, ... }@inputs:
    let
      # A NixOS/nix-darwin module is just an attrset, so we can inline one here
      # instead of giving a single option its own file. Overlays registered via
      # `nixpkgs.overlays` apply to the system pkgs, which Home Manager reuses
      # because both hosts set `useGlobalPkgs = true`.
      overlaysModule = {
        nixpkgs.overlays = [ inputs.claude-code.overlays.default ];
      };
    in
    {
      nixosConfigurations.wsl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          nixos-wsl.nixosModules.default
          home-manager.nixosModules.home-manager
          overlaysModule
          ./hosts/wsl
        ];
      };

      darwinConfigurations.darwin = nix-darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        specialArgs = { inherit inputs; };
        modules = [
          home-manager.darwinModules.home-manager
          overlaysModule
          ./hosts/darwin
        ];
      };

      templates.java = {
        path = ./templates/java;
        description = "Java devShell with JDK and Maven";
      };
    };
}
