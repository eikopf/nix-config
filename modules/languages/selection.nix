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
    # we refer to lang.packages.content here to force the evaluation of the
    # package list; this is necessary due to how derivations differ from ordinary
    # nix values
    environment.systemPackages = lib.concatMap (lang: lang.packages.content) langs;
    environment.variables = lib.mergeAttrsList (map (lang: lang.env) langs);
  };
}
