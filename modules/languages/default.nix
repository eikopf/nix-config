# programming language configurations as a proper NixOS/darwin module
#
# each language has a corresponding option `languages.<name>.enable` which,
# when set to true, adds the language's packages to `environment.systemPackages`
# and any associated environment variables to `environment.variables`.

{
  lib,
  config,
  pkgs,
  ...
}:

let
  # per-language definitions: each entry has `packages` (list) and optionally
  # `env` (attrset of strings). these are plain values, not functions —
  # packages come from the module's own `pkgs`, so no second nixpkgs eval.
  langDefs = {
    agda = {
      packages = with pkgs; [ agda ];
      env.AGDA_DIR = "$HOME/.config/agda";
    };

    c = {
      packages = with pkgs; [
        gcc
        clang-tools
      ];
    };

    chez = {
      packages = with pkgs; [ chez ];
      env = {
        CHEZSCHEMELIBDIRS = "$HOME/.local/lib/scheme:";
        CHEZSCHEMELIBEXTS = ".scm::.so:";
      };
    };

    clojure = {
      packages = with pkgs; [
        clojure
        cljfmt
        clojure-lsp
      ];
      env.CLJ_CONFIG = "$HOME/.config/clojure";
    };

    haskell = {
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
    };

    hledger = {
      packages = with pkgs; [
        hledger
      ];
    };

    idris2 = {
      packages = with pkgs; [
        idris2
        idris2Packages.idris2Lsp
        idris2Packages.pack
      ];
    };

    janet = {
      packages = with pkgs; [ janet ];
    };

    java = {
      packages = with pkgs; [
        zulu
        jdt-language-server # jdtls
      ];
    };

    javascript = {
      packages = with pkgs; [
        nodejs
        typescript-language-server # ts_ls
        prettierd
      ];
    };

    lean = {
      packages = with pkgs; [ elan ];
    };

    lua = {
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
    };

    markdown = {
      packages = with pkgs; [
        marksman
      ];
    };

    nix = {
      packages = with pkgs; [
        nixd
        nixfmt
      ];
    };

    ocaml = {
      packages = with pkgs; [
        ocaml
        dune_3
        ocamlPackages.utop
        ocamlPackages.ocaml-lsp
        ocamlPackages.ocamlformat
      ];
    };

    python = {
      packages = with pkgs; [
        uv
        ruff
        pyright
      ];
    };

    racket = {
      packages = with pkgs; [ racket-minimal ];
    };

    # NOTE: some tools (for example, espup) assume that the rust-analyzer binary
    # on the PATH is the independent one, but if they run into rustup's version then
    # they'll crash. conversely, if the independent rust-analyzer package is too old
    # relative to the current version of rustc, it will stop being able to handle
    # macro expansions correctly. so deciding whether to include the independent
    # rust-analyzer or not is a matter of deciding which of these crashes you would
    # most like to avoid

    rust = {
      packages = with pkgs; [
        # (lib.setPrio 0 rust-analyzer)
        rustup
      ];
    };

    typst = {
      packages = with pkgs; [
        typst
        typstyle
        tinymist
      ];
    };
  };

  # generate options: one `languages.<name>.enable` per language
  languageOptions = lib.mapAttrs (name: _: {
    enable = lib.mkEnableOption "the ${name} programming language environment";
  }) langDefs;

  # collect enabled language definitions
  enabledDefs = lib.filterAttrs (name: _: config.languages.${name}.enable) langDefs;
in
{
  options.languages = languageOptions;

  config = {
    environment.systemPackages = lib.concatMap (def: def.packages or [ ]) (lib.attrValues enabledDefs);

    # attribute names are statically determined by `langDefs` (those that have
    # an `env` key), so they never depend on `config.environment.variables` —
    # only the values may reference it, which is safe.
    environment.variables = lib.mkMerge (
      lib.mapAttrsToList (_: def: def.env) (lib.filterAttrs (_: def: def ? env) enabledDefs)
    );
  };
}
