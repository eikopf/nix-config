# definitions for the language selection API

{
  lib,
  config,
  languages,
  ...
}:
{
  options.languages = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "List of enabled programming languages.";
  };

  config = {
    languages = lib.mkMerge (map (lang: { languages.${lang}.enable = true; }) config.languages);

    imports = map (lang: lib.attrByPath [ lang ] { } languages) config.languages;
  };
}
