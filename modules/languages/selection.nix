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
    environment.systemPackages = lib.concatMap (lang: lang.packages) langs;
    environment.variables = lib.mergeAttrsList (map (lang: lang.env or { }) langs);
  };
}
