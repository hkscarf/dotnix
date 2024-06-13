{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/release-23.11";
    # nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable"; # TODO Enable both stable and unstable
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { home-manager, nix-darwin, ... }:
    {
      darwinConfigurations."HKs-MacBook-Air" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
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
