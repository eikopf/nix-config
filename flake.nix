{
  description = "Core Nix configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      darwin,
      home-manager,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      inherit (nixpkgs) lib;

      mkNixosHost =
        name: system: extraModules:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs outputs;
            languages = import ./modules/languages {
              inherit lib;
              pkgs = import nixpkgs { inherit system; };
            };
          };

          modules = [
            ./hosts/${name}
            ./modules/common
            ./modules/languages/selection.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.oliver = (import ./home);
            }
          ] ++ extraModules;
        };

      mkDarwinHost =
        name: system: extraModules:
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = {
            inherit self inputs outputs;
            languages = import ./modules/languages {
              inherit lib;
              pkgs = import nixpkgs { inherit system; };
            };
          };

          modules = [
            ./hosts/${name}
            ./modules/common
            ./modules/darwin
            ./modules/languages/selection.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.oliver = import ./home;
            }
          ] ++ extraModules;
        };
    in
    {
      nixosConfigurations = {
        rigi = mkNixosHost "rigi" "x86_64-linux" [ ];
      };

      darwinConfigurations = {
        pilatus = mkDarwinHost "pilatus" "aarch64-darwin" [ ];
      };
    };
}
