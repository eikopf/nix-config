{
  lib,
  config,
  languages,
  ...
}:

let
  activeLanguages = builtins.listToAttrs (
    map (lang: {
      name = lang;
      value = languages.${lang}.cfgFn config;
    }) config.enabledLanguages
  );
in
{
  options.enabledLanguages = lib.mkOption {
    type = lib.types.listOf (lib.types.enum (builtins.attrNames languages));
    default = [ ];
    description = "List of enabled programming language configurations.";
  };

  config = {
    environment.systemPackages = lib.flatten (
      map (lang: activeLanguages.${lang}.packages) config.enabledLanguages
    );

    environment.variables = lib.mkMerge (
      map (
        lang:
        let
          langConfig = activeLanguages.${lang};
        in
        lib.mkIf (builtins.elem lang config.enabledLanguages) langConfig.env
      ) config.enabledLanguages
    );
  };
}
