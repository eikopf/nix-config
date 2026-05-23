{
  description = "Core Nix configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.11";
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
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      darwin,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      home-manager,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      inherit (nixpkgs) lib;

      mkLanguages =
        system:
        import ./modules/languages {
          inherit lib;
          pkgs = import nixpkgs { inherit system; };
        };

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
          extraModules,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit user inputs outputs;
            languages = mkLanguages system;
          };

          modules = [
            ./hosts/${name}
            ./modules/common
            ./modules/nixos
            ./modules/languages/selection.nix
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
          extraModules,
        }:
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = {
            inherit
              self
              user
              inputs
              outputs
              ;
            languages = mkLanguages system;
          };

          modules = [
            ./hosts/${name}
            ./modules/common
            ./modules/darwin
            ./modules/languages/selection.nix
            home-manager.darwinModules.home-manager
            nix-homebrew.darwinModules.nix-homebrew
            (
              mkHomeManagerModule user
              // {
                nix-homebrew = {
                  inherit user;
                  enable = true;

                  # declare taps explicitly
                  taps = {
                    "homebrew/homebrew-core" = homebrew-core;
                    "homebrew/homebrew-cask" = homebrew-cask;
                  };

                  # disable imperatively added taps
                  mutableTaps = false;
                };
              }
            )

            # set homebrew.taps to the declared nix-homebrew taps
            (
              { config, ... }:
              {
                homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
              }
            )
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
          extraModules = [ ];
        };

        wildspitz = mkNixosHost {
          user = "oliver";
          name = "wildspitz";
          system = "x86_64-linux";
          extraModules = [ ];
        };
      };

      darwinConfigurations = {
        pilatus = mkDarwinHost {
          user = "oliver";
          name = "pilatus";
          system = "aarch64-darwin";
          extraModules = [ ];
        };
      };
    };
}
