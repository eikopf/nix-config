# shell configuration for all hosts

{ pkgs, ... }:
let
  shellAliases = {
    # git
    gs = "git status";
    gl = "git log --graph --decorate --oneline --all";

    # jujutsu (jj)
    js = "jj status --no-pager";
    jl = "jj log --no-pager";

    # eza
    exa = "eza";
    ezaa = "eza -alh";
  };
in
{
  programs.fish = {
    enable = true;
    shellAliases = shellAliases;
  };

  environment.systemPackages = with pkgs; [
    atuin
    eza
    fish
    fzf
    hyfetch
    jq
    jujutsu
    pandoc
    ripgrep
    starship
    tree-sitter
    tlrc
    zoxide
  ];

  environment.variables = rec {
    # general shell settings
    EDITOR = "nvim";

    # XDG directories
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";

    # program-specific settings
    RLWRAP_HOME = "$HOME/.local/rlwrap"; # rlwrap
    TLDR_ROOT = "${XDG_CONFIG_HOME}/tldr"; # tldr
    _ZO_DATA_DIR = "${XDG_DATA_HOME}"; # zoxide
  };
}
