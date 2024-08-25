{
  description = "A dev environment for Warren";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: 
  flake-utils.lib.eachDefaultSystem 
  (system:
    let
      pkgs = import nixpkgs {
	inherit system;
      };
      dc = pkgs.diesel-cli.override {
	sqliteSupport = false;
	mysqlSupport = false;
      };
    in 
    {
      devShells.default = nixpkgs.legacyPackages.${system}.mkShell {
	nativeBuildInputs = with pkgs; [ 
	  rustup 
	  dc
	  postgresql
	];
      };

      nixosConfigurations = {
	server = nixpkgs.lib.nixosSystem {
	  system = system;
	  modules = [
	    ./configuration.nix 
	  ];
	};
      };
    }
  );
}
