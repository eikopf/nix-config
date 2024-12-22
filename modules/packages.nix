# the basic packages installed by all hosts

{
  pkgs,
  ...
}: with pkgs; [
  # essentials
  curl
  git
  readline
  rlwrap
  tree
  vim
  wget

  # terminal emulator
  kitty

  # shell & cli
  eza
  fish
  fzf
  hyfetch
  jq
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
]
