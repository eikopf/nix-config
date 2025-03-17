{ ... }:
{
  nixpkgs.overlays = [
    # https://github.com/LnL7/nix-darwin/issues/1041
    (final: prev: {
      karabiner-elements = prev.karabiner-elements.overrideAttrs (old: {
        version = "14.13.0";

        src = prev.fetchurl {
          inherit (old.src) url;
          hash = "sha256-gmJwoht/Tfm5qMecmq1N6PSAIfWOqsvuHU8VDJY8bLw=";
        };
      });
    })
  ];
}
