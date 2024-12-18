# home-manager configuration for pilatus

{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    rectangle       # window manager
    tree-sitter     # builds local grammars for neovim

    # languages
    chez                    # chezscheme
    elan                    # lean
    idris2                  # idris2
    janet                   # janet
    julia-bin               # julia
    luajit                  # lua
    luajitPackages.fennel   # fennel
    nodejs                  # javascript
    racket-minimal          # racket
    rustup                  # rust
    zulu23                  # java
  ];
}
