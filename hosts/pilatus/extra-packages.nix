{
  pkgs,
  ...
}:
with pkgs;
[
  # macOS utilities
  skhd
  yabai

  # languages
  chez # chezscheme
  elan # lean
  ghc # haskell
  go # go
  idris2 # idris2
  janet # janet
  luajit # lua
  luajitPackages.fennel # fennel
  nodejs # javascript
  ocaml # ocaml
  racket-minimal # racket
  rustup # rust
  zulu23 # java

  # LANGUAGE TOOLING

  # general
  tree-sitter

  # idris
  idris2Packages.idris2Lsp

  # lua/fennel
  fennel-ls
  luajitPackages.readline

  # ocaml
  dune_3
  ocamlPackages.utop
  ocamlPackages.ocaml-lsp
  ocamlPackages.ocamlformat

  # haskell-tools.nvim prerequisites
  haskellPackages.fast-tags
  haskellPackages.haskell-debug-adapter
  haskellPackages.haskell-language-server
  haskellPackages.hoogle
  haskellPackages.stack
]
