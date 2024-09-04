{ pkgs, config, modulesPath, ... }:
let
    dc = pkgs.diesel-cli.override {
      sqliteSupport = false;
      mysqlSupport = false;
    };

    buildPackage = pname: version:
      pkgs.rustPlatform.buildRustPackage rec {
        inherit pname version;
        src = ./${pname};
        cargoLock = { lockFile = ./${pname}/Cargo.lock; };
      };
in
with config;
{
  nixpkgs.hostPlatform = "x86_64-linux";
  imports = [
    #"${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];
  environment.systemPackages = with pkgs; [
    rustup
    dc
    postgresql
    firefox
    neovim
    disko
    parted
    git
    ( buildPackage "warren-server" "0.1.0" )
  ];

    services.postgresql = {
        enable = true;
        ensureDatabases = [ "warren" ];
        ensureUsers = [
            {
                name = "warren";
                ensureDBOwnership = true;
                ensureClauses = {
                  superuser = true;
                  createrole = true;
                  createdb = true;
                };
            }
        ];
        enableTCPIP = true;
        authentication = pkgs.lib.mkOverride 10 ''
        #type	database	DBuser	origin-address	auth-method
        local	all	all			trust
        host	all	all	127.0.0.1/32	trust 
        host 	all 	all 	::1/128 	trust
        '';
    };

  nixpkgs = {
    config.allowUnfree = true;
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      experimental-features = "nix-command flakes";

      flake-registry = "";

      nix-path = config.nix.nixPath;
    };
    channel.enable = true;
  };

  networking.hostName = "Warren-Server";

  users.users = {
    sys-admin = {
      name = "sys-admin";
      password = "temp123";
      isNormalUser = true;
      extraGroups = ["wheel"];
    };

    warren = {
      name = "warren";
      password = "temp123";
      isNormalUser = true;
    };
  };

  services.openssh = {
    enable = true;
  };

  services.getty.autologinUser = "root";

  console.keyMap = "dvorak";

  system.stateVersion = "24.11";
}
