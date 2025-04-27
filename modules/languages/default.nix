# programming language configurations

# each element in this module is an attribute set with two fields:
# - the `name` field is a string with the name of the language, and;
# - the `cfgFn` field is a function which takes an attribute set and returns
#   an attribute set.
#
# the input to each `cfgFn` is presumed to the be the `config` parameter passed
# to host configuration modules, and the output has two optional fields:
# - the `packages` field is a list of the elements of `pkgs`, and;
# - the `env` field is an attribute set of strings defining environment variables.
#
# the processing of these language configurations is defined in ./selection.nix

{ pkgs, ... }:

let
  mkLang = name: cfgFn: {
    inherit name cfgFn;
  };
in
{
  agda = mkLang "agda" (config: {
    packages = with pkgs; [ agda ];
    env.AGDA_DIR = "${config.environment.variables.XDG_CONFIG_HOME}/agda";
  });

  c = mkLang "c" (config: {
    packages = with pkgs; [
      clang-tools
    ];
  });

  chez = mkLang "chez" (config: {
    packages = with pkgs; [ chez ];
    env = {
      CHEZSCHEMELIBDIRS = "$HOME/.local/lib/scheme:";
      CHEZSCHEMELIBEXTS = ".scm::.so:";
    };
  });

  clojure = mkLang "clojure" (config: {
    packages = with pkgs; [
      clojure
      cljfmt
      clojure-lsp
    ];
    env.CLJ_CONFIG = "${config.environment.variables.XDG_CONFIG_HOME}/clojure";
  });

  haskell = mkLang "haskell" (config: {
    packages = [
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
  });

  idris2 = mkLang "idris2" (config: {
    packages = with pkgs; [
      idris2
      idris2Packages.idris2Lsp
      idris2Packages.pack
    ];
  });

  janet = mkLang "janet" (config: {
    packages = with pkgs; [ janet ];
  });

  java = mkLang "java" (config: {
    packages = with pkgs; [
      zulu23
      jdt-language-server # jdtls
    ];
  });

  javascript = mkLang "javascript" (config: {
    packages = with pkgs; [
      nodejs
      typescript-language-server # ts_ls
      prettierd
    ];
  });

  lean = mkLang "lean" (config: {
    packages = with pkgs; [ elan ];
  });

  lua = mkLang "lua" (config: {
    packages = with pkgs; [
      lua-language-server
      fennel-ls
      fnlfmt
      (luajit.withPackages (
        ps: with ps; [
          fennel
          readline
        ]
      ))
    ];
  });

  nix = mkLang "nix" (config: {
    packages = with pkgs; [
      nixd
      nixfmt-rfc-style
    ];
  });

  ocaml = mkLang "ocaml" (config: {
    packages = with pkgs; [
      ocaml
      dune_3
      ocamlPackages.utop
      ocamlPackages.ocaml-lsp
      ocamlPackages.ocamlformat
    ];
  });

  python = mkLang "python" (config: {
    packages = with pkgs; [
      uv
      ruff
      ruff-lsp
    ];
  });

  racket = mkLang "racket" (config: {
    packages = with pkgs; [ racket-minimal ];
  });

  rust = mkLang "rust" (config: {
    packages = with pkgs; [ rustup ];
  });

  typst = mkLang "typst" (config: {
    packages = with pkgs; [
      typst
      typstyle
      tinymist
    ];
  });
}
