# the basic packages installed by all hosts

{
  pkgs,
  ...
}:
with pkgs;
[
  # essentials
  curl
  git
  readline
  rlwrap
  tree
  vim
  wget

  # nix-specifics
  devenv
  nixfmt-rfc-style

  # terminal emulator
  kitty

  # shell & cli
  eza
  fish
  fzf
  hyfetch
  jq
  jujutsu
  pandoc
  ripgrep
  starship
  tlrc
  zoxide

  # languages
  chez
  janet
  nodejs
  rustup
  uv
]
