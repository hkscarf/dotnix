{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/release-23.11";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devenv.url = "github:cachix/devenv";
    tie = {
      url = "github:piq9117/tie/piq9117/flake.nix"; # flake-based fork of github:scarf-sh/tie on ghc-9.0.2

    };
  };

  outputs = { home-manager, nix-darwin, ... }:
    {
      darwinConfigurations."HKs-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        modules = [
          ./darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.hkscarf = import ./home.nix;
          }
        ];
      };
    };
}
