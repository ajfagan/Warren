{
  description = "A dev environment for Warren";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@attrs: 
    flake-utils.lib.eachDefaultSystem (system: 
      let
	pkgs = nixpkgs.legacyPackages.${system};
	dc = pkgs.diesel-cli.override {
	  sqliteSupport = false;
	  mysqlSupport = false;
	};
	warren = pkgs.writeShellApplication {
	  name = "warren";

	  runtimeInputs = with pkgs; [ 
	    rustup
	    dc
	    postgresql
	  ];

	  text = (builtins.readFile ./warren.sh);
	};
      in 
      {
	devShells.default = pkgs.mkShell {
	  nativeBuildInputs = with pkgs; [ 
	    rustup 
	    dc
	    postgresql
	    warren
	  ];
	};

	nixosConfigurations = {
	  server = {
	    default = attrs.nixpkgs.lib.nixosSystem {
	      inherit system;
	      specialArgs = { inherit attrs; };
	      modules = [
		./configuration.nix 
	      ];
	    };
	  };
	};
      };
    );
}
