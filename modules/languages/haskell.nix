# haskell language module

{ pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.haskellPackages.ghc.withPackages (
      ps: with ps; [
        fast-tags
        haskell-debug-adapter
        haskell-language-server
        hoogle
        stack
      ]
    ))
  ];
}
