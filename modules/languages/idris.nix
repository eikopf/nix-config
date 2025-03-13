# idris language module
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    idris2
    idris2Packages.idris2Lsp
    idris2Packages.pack
  ];
}
