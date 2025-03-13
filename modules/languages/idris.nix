# idris language module
{ pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.idris2.withPackages (
      ps: with ps; [
        idris2Lsp
        pack
      ]
    ))
  ];
}
