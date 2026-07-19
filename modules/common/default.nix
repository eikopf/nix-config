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
    gh
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
