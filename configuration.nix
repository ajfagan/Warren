{ pkgs, config, modulesPath, ... }:
let
    dc = pkgs.diesel-cli.override {
      sqliteSupport = false;
      mysqlSupport = false;
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
  ];

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "Warren" ];
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

  users.mutableUsers = false;
  users.users = {
    sys-admin = {
      name = "sys-admin";
      initialHashedPassword = "";
      isNormalUser = true;
      extraGroups = ["wheel"];
    };
  };

  services.openssh = {
    enable = true;
  };

  system.stateVersion = "24.11";
}
