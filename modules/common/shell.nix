# shell configuration for all hosts

{ pkgs, ... }:
let
  shellAliases = {
    # git
    gs = "git status";
    gl = "git log --graph --decorate --oneline --all";

    # jujutsu
    js = "jj status --no-pager";
    jl = "jj log --no-pager";

    # eza
    ezaa = "eza -alh";
  };
in
{
  programs.fish = {
    enable = true;
    shellAliases = shellAliases;
  };

  # Tools configured via home-manager (home/) are intentionally not listed here;
  # home-manager owns their installation alongside their configuration.
  environment.systemPackages = with pkgs; [
    fish # must be system-level so NixOS registers it in /etc/shells
    fzf
    jq
    man
    man-pages
    man-pages-posix
    pandoc
    ripgrep
    tree-sitter
    tlrc
  ];

  environment.variables = {
    # Fallback editor for root and other non-home-manager contexts (NixOS
    # otherwise defaults this to nano). User sessions get EDITOR = nvim from
    # home/neovim.nix; vim is used here because it's installed system-wide.
    EDITOR = "vim";

    # XDG directories
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";

    # program-specific settings
    RLWRAP_HOME = "$HOME/.local/rlwrap"; # rlwrap
  };
}
