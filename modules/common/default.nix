{ pkgs, ... }:
{
  imports = [
    ./nix.nix
    ./shell.nix
    ./users.nix
  ];

  # base packages installed by all hosts
  # Tools configured via home-manager (home/) are intentionally not listed here;
  # home-manager owns their installation alongside their configuration.
  environment.systemPackages = with pkgs; [
    git-extras
    readline
    rlwrap
    tree
    vim
    wget
    curl
    fish # must be system-level so NixOS registers it in /etc/shells
    hyperfine
    just
  ];
}
