# agda language module

{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ agda ];

  environment.variables = {
    AGDA_DIR = "${config.environment.variables.XDG_CONFIG_HOME}/agda";
  };
}
