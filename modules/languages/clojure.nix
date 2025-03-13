# clojure language module

{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ clojure ];

  environment.variables = {
    CLJ_CONFIG = "${config.environment.variables.XDG_CONFIG_HOME}/clojure";
  };
}
