{
  description = "Core Nix configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    darwin = {
      url = "github:LnL7/nix-darwin/";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self, 
    nixpkgs, 
    darwin,
    home-manager,
    ... 
  } @ inputs: let
      inherit (self) outputs;
  in {
    # nixOS systems
    nixosConfigurations = {
      rigi = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
	    system = "x86_64-linux";
        modules = [
          ./hosts/rigi
	      home-manager.nixosModules.home-manager
	        {
              home-manager.useGlobalPkgs = true;
	          home-manager.useUserPackages = true;
	          home-manager.backupFileExtension = "backup";
	          home-manager.users.oliver = (import ./home);
	        }
        ];
      };
    };

    # macOS systems
    darwinConfigurations = {
      pilatus = darwin.lib.darwinSystem {
      specialArgs = {inherit inputs outputs;};
      system = "aarch64-darwin";
        modules = [
          ./hosts/pilatus
	      home-manager.darwinModules.home-manager
	      {
            home-manager.useGlobalPkgs = true;
	        home-manager.useUserPackages = true;
	        home-manager.backupFileExtension = "backup";
	        home-manager.users.oliver = {
              imports = [
                ./home
                ./hosts/pilatus/home.nix
              ];
            };
	      }
        ];
      };
    };
  };
}
