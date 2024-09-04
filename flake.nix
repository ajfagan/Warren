{
  description = "A dev environment for Warren";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
	home-manager = {
		url = "github:nix-community/home-manager";
		inputs.nixpkgs.follows = "nixpkgs";
	};
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, ... }@attrs: 
    flake-utils.lib.eachDefaultSystem (system: 
      let
	pkgs = nixpkgs.legacyPackages.${system};
	dc = pkgs.diesel-cli.override {
	  sqliteSupport = false;
	  mysqlSupport = false;
	};
      in 
      {

	nixosConfigurations = {
	  server = {
	    default = attrs.nixpkgs.lib.nixosSystem {
	      inherit system;
	      specialArgs = { inherit attrs; };
	      modules = [
			./configuration.nix 
			home-manager.nixosModules.home-manager {
				home-manager.useGlobalPkgs = true;
				home-manager.useUserPackages = true;
				home-manager.users.warren = import ./warren-server/warren.nix;
			}
	      ];
	    };
	  };
	};
      }
    );
}
