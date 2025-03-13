# ocaml language module

{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ocaml
    dune_3
    ocamlPackages.utop
    ocamlPackages.ocaml-lsp
    ocamlPackages.ocamlformat
  ];
}
