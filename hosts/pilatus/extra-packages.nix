{
  pkgs,
  ...
}:
with pkgs;
[
  # GUIs
  rectangle # window manager

  # languages
  chez # chezscheme
  elan # lean
  go # go
  idris2 # idris2
  janet # janet
  julia-bin # julia
  luajit # lua
  luajitPackages.fennel # fennel
  nodejs # javascript
  opam # ocaml
  racket-minimal # racket
  rustup # rust
  zulu23 # java

  # language tooling
  tree-sitter # builds local grammars for neovim
  idris2Packages.idris2Lsp # idris2 LSP
]
