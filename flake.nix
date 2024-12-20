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
    nixosConfigurations.rigi = nixpkgs.lib.nixosSystem {
	  system = "x86_64-linux";
      specialArgs = { inherit inputs outputs; };

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

    # macOS systems
    darwinConfigurations.pilatus = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = { inherit self inputs outputs; };

      modules = [
        ./hosts/pilatus
	    home-manager.darwinModules.home-manager
	    {
          home-manager.useGlobalPkgs = true;
	      home-manager.useUserPackages = true;
	      home-manager.backupFileExtension = "backup";
	      home-manager.users.oliver = import ./home;
          home-manager.extraSpecialArgs.extraPkgs 
            = import ./hosts/pilatus/extra-packages.nix {pkgs = nixpkgs;};
        }
      ];
    };
  };
}
