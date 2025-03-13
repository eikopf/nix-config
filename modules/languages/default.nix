# per-language configuration sets

{
  lib,
  config,
  pkgs,
  ...
}:
{
  agda = {
    options.languages.agda.enable = lib.mkEnableOption "Enable Agda support";
    config = lib.mkIf config.languages.agda.enable {
      environment.systemPackages = with pkgs; [ agda ];

      environment.variables = {
        AGDA_DIR = "${config.environment.variables.XDG_CONFIG_HOME}/agda";
      };
    };
  };

  chez = {
    options.languages.chez.enable = lib.mkEnableOption "Enable Chez support";
    config = lib.mkIf config.languages.chez.enable {
      environment.systemPackages = [ pkgs.chez ];

      environment.variables = {
        CHEZSCHEMELIBDIRS = "$HOME/.local/lib/scheme:";
        CHEZSCHEMELIBEXTS = ".scm::.so:";
      };
    };
  };

  clojure = {
    options.languages.clojure.enable = lib.mkEnableOption "Enable Clojure support";
    config = lib.mkIf config.languages.clojure.enable {
      environment.systemPackages = with pkgs; [ clojure ];

      environment.variables = {
        CLJ_CONFIG = "${config.environment.variables.XDG_CONFIG_HOME}/clojure";
      };
    };
  };

  haskell = {
    options.languages.haskell.enable = lib.mkEnableOption "Enable Haskell support";
    config = lib.mkIf config.languages.haskell.enable {
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
    };
  };

  idris2 = {
    options.languages.idris2.enable = lib.mkEnableOption "Enable Idris2 support";
    config = lib.mkIf config.languages.idris2.enable {
      environment.systemPackages = with pkgs; [
        idris2
        idris2Packages.idris2Lsp
        idris2Packages.pack
      ];
    };
  };

  janet = {
    options.languages.janet.enable = lib.mkEnableOption "Enable Janet support";
    config = lib.mkIf config.languages.janet.enable {
      environment.systemPackages = with pkgs; [ janet ];
    };
  };

  java = {
    options.languages.java.enable = lib.mkEnableOption "Enable Java support";
    config = lib.mkIf config.languages.java.enable {
      environment.systemPackages = with pkgs; [ zulu23 ];
    };
  };

  javascript = {
    options.languages.javascript.enable = lib.mkEnableOption "Enable JavaScript support";
    config = lib.mkIf config.languages.javascript.enable {
      environment.systemPackages = with pkgs; [ nodejs ];
    };
  };

  lean = {
    options.languages.lean.enable = lib.mkEnableOption "Enable Lean support";
    config = lib.mkIf config.languages.lean.enable {
      environment.systemPackages = with pkgs; [ elan ];
    };
  };

  lua = {
    options.languages.lua.enable = lib.mkEnableOption "Enable Lua support";
    config = lib.mkIf config.languages.lua.enable {
      environment.systemPackages = with pkgs; [
        fennel-ls
        (luajit.withPackages (
          ps: with ps; [
            fennel
            readline
          ]
        ))
      ];
    };
  };

  ocaml = {
    options.languages.ocaml.enable = lib.mkEnableOption "Enable OCaml support";
    config = lib.mkIf config.languages.ocaml.enable {
      environment.systemPackages = with pkgs; [
        ocaml
        dune_3
        ocamlPackages.utop
        ocamlPackages.ocaml-lsp
        ocamlPackages.ocamlformat
      ];
    };
  };

  python = {
    options.languages.python.enable = lib.mkEnableOption "Enable Python support";
    config = lib.mkIf config.languages.python.enable {
      environment.systemPackages = with pkgs; [ uv ];
    };
  };

  racket = {
    options.languages.racket.enable = lib.mkEnableOption "Enable Racket support";
    config = lib.mkIf config.languages.racket.enable {
      environment.systemPackages = with pkgs; [ racket-minimal ];
    };
  };

  rust = {
    options.languages.rust.enable = lib.mkEnableOption "Enable Rust support";
    config = lib.mkIf config.languages.rust.enable {
      environment.systemPackages = with pkgs; [ rustup ];
    };
  };
}
