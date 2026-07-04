{ pkgs, ... }:
{
  imports = [
    ./nix.nix
    ./shell.nix
    ./users.nix
  ];

  # base packages installed by all hosts
  environment.systemPackages = with pkgs; [
    git-extras
    gnupg
    readline
    rlwrap
    tree
    vim
    wget
    curl
    fish
    hyperfine
    just
  ];
}
