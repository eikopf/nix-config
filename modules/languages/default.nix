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

  chez = mkLang "chez" (config: {
    packages = with pkgs; [ chez ];
    env = {
      CHEZSCHEMELIBDIRS = "$HOME/.local/lib/scheme:";
      CHEZSCHEMELIBEXTS = ".scm::.so:";
    };
  });

  clojure = mkLang "clojure" (config: {
    packages = with pkgs; [ clojure ];
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

  idris = mkLang "idris" (config: {
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
    packages = with pkgs; [ zulu23 ];
  });

  javascript = mkLang "javascript" (config: {
    packages = with pkgs; [ nodejs ];
  });

  lean = mkLang "lean" (config: {
    packages = with pkgs; [ elan ];
  });

  lua = mkLang "lua" (config: {
    packages = with pkgs; [
      fennel-ls
      (luajit.withPackages (
        ps: with ps; [
          fennel
          readline
        ]
      ))
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
    packages = with pkgs; [ uv ];
  });

  racket = mkLang "racket" (config: {
    packages = with pkgs; [ racket-minimal ];
  });

  rust = mkLang "rust" (config: {
    packages = with pkgs; [ rustup ];
  });
}
