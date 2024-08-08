{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/release-24.05";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable"; # TODO Enable both stable and unstable
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { home-manager, nix-darwin, nixpkgs-unstable, ... }:
    {
      darwinConfigurations."HKs-MacBook-Air" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          pkgsUnstable = import nixpkgs-unstable {
            system = "aarch64-darwin";
          };
        };
        modules = [
          ./darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.hkscarf = import ./home.nix;
            home-manager.extraSpecialArgs = {
              pkgsUnstable = nixpkgs-unstable {
                system = "aarch64-darwin";
              };
            };
          }
        ];
      };
    };
}
