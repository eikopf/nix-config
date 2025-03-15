# simple module for applying `config.enabledLanguages` to the configuration

# this module is responsible for
# 1. defining the `enabledLanguages` option, and;
# 2. processing `config.enabledLanguages` to update the configuration.

{
  lib,
  config,
  ...
}:

let
  langs = map (lang: lang.cfgFn config) config.enabledLanguages;
in
{
  options.enabledLanguages = lib.mkOption {
    type = lib.types.listOf lib.types.attrs; # not perfectly accurate
    default = [ ];
    description = "List of enabled programming language configurations.";
  };

  config = {
    environment.systemPackages = lib.concatMap (lang: lang.packages or [ ]) langs;
    environment.variables = lib.mergeAttrsList (map (lang: lang.env or { }) langs);
  };
}
