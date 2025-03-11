{
  pkgs,
  ...
}:
with pkgs;
[
  # window manager
  # rectangle
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

  # language tooling
  dune_3
  tree-sitter
  fennel-ls
  idris2Packages.idris2Lsp
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
