{ config, pkgs, ... }:
let 
    pname = "warren-server";
    version = "0.1.0";
    buildPackage = (pkgs.rustPlatform.buildRustPackage rec {
      inherit pname version;
      src = ./.;
      cargoLock = { lockFile = ./Cargo.lock; };
    });
in
{
    home.username = "warren";
    home.homeDirectory = "/home/warren";

    home.packages = [
        buildPackage
    ];

    home.stateVersion = "24.11";

    programs.home-manager.enable = true;
}