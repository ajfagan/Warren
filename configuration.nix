{ pkgs, config, ... }:
let
    dc = pkgs.diesel-cli.override {
      sqliteSupport = false;
      mysqlSupport = false;
    };
in
{
  environment.systemPackages = with pkgs; [
    rustup
    dc
    postgresql
    firefox
  ]; 

  config.services.postgresql = {
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
}
