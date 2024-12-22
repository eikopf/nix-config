# common environment variables

rec {
  # XDG directories
  XDG_CACHE_HOME = "$HOME/.cache";
  XDG_CONFIG_HOME = "$HOME/.config";
  XDG_DATA_HOME = "$HOME/.local/share";
  XDG_STATE_HOME = "$HOME/.local/state";

  # program-specific environment variables
  AGDA_DIR = "${XDG_CONFIG_HOME}/agda"; # agda
  CLJ_CONFIG = "${XDG_CONFIG_HOME}/clojure"; # clojure
  RLWRAP_HOME = "$HOME/.local/rlwrap"; # rlwrap
  TLDR_ROOT = "${XDG_CONFIG_HOME}/tldr"; # tldr
  _ZO_DATA_DIR = "${XDG_DATA_HOME}"; # zoxide

  # chezscheme
  CHEZSCHEMELIBDIRS = "$HOME/.local/lib/scheme:";
  CHEZSCHEMELIBEXTS = ".scm::.so:";
}
