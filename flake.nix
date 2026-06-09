{
  description = "Core Nix configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };

    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      darwin,
      nix-homebrew,
      home-manager,
      ...
    }@inputs:
    let
      inherit (nixpkgs) lib;

      mkHomeManagerModule = user: {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
        home-manager.extraSpecialArgs = { inherit user; };
        home-manager.users.${user} = import ./home;
      };

      mkNixosHost =
        {
          user,
          name,
          system,
          extraModules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit user;
          };

          modules = [
            ./hosts/${name}
            ./modules/common
            ./modules/nixos
            ./modules/languages
            home-manager.nixosModules.home-manager
            (mkHomeManagerModule user)
          ]
          ++ extraModules;
        };

      mkDarwinHost =
        {
          user,
          name,
          system,
          extraModules ? [ ],
        }:
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = {
            inherit self user inputs;
          };

          modules = [
            ./hosts/${name}
            ./modules/common
            ./modules/darwin
            ./modules/languages
            home-manager.darwinModules.home-manager
            nix-homebrew.darwinModules.nix-homebrew
            (mkHomeManagerModule user)
          ]
          ++ extraModules;
        };
    in
    {
      nixosConfigurations = {
        rigi = mkNixosHost {
          user = "oliver";
          name = "rigi";
          system = "x86_64-linux";
        };

        wildspitz = mkNixosHost {
          user = "oliver";
          name = "wildspitz";
          system = "x86_64-linux";
        };
      };

      darwinConfigurations = {
        pilatus = mkDarwinHost {
          user = "oliver";
          name = "pilatus";
          system = "aarch64-darwin";
        };
      };
    };
}
