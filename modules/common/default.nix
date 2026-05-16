{ pkgs, ... }:
{
  imports = [
    ./nix.nix
    ./shell.nix
    ./users.nix
  ];

  # base packages installed by all hosts
  environment.systemPackages = with pkgs; [
    git
    git-extras
    readline
    rlwrap
    tree
    vim
    wget
    curl
    neovim
    fish
    hyperfine
    just
  ];
}
