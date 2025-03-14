{
  lib,
  config,
  languages,
  ...
}:

let
  activeLanguages = map (lang: languages.${lang.name}.cfgFn config) config.enabledLanguages;
in
{
  options.enabledLanguages = lib.mkOption {
    type = lib.types.listOf lib.types.attrs; # not perfectly accurate
    default = [ ];
    description = "List of enabled programming language configurations.";
  };

  config = {
    environment.systemPackages = lib.flatten (map (lang: lang.packages.content) activeLanguages);

    environment.variables = builtins.foldl' (
      acc: langCfg: acc // langCfg.env.content
    ) { } activeLanguages;
  };
}
