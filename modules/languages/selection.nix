# definitions for the language selection API

{
  lib,
  config,
  languages,
  ...
}:
{
  options.enabledLanguages = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "List of enabled programming languages.";
  };

  config = {
    languages = lib.mkMerge (map (lang: { languages.${lang}.enable = true; }) config.enabledLanguages);

    imports = lib.attrsets.attrValues (
      lib.filterAttrs (lang: _: lang != null && languages ? ${lang}) languages
    );
  };
}
