{ pkgs, lib, ... }:
{
  imports = [
    ./nix.nix
    ./shell.nix
    ./users.nix
  ];

  environment.systemPackages = lib.mkMerge [
    (import ./base.nix).environment.systemPackages
    (import ./shell.nix).environment.systemPackages

    # base packages installed by all hosts
    (with pkgs; [
      git
      readline
      rlwrap
      tree
      vim
      wget
      curl
      neovim
      fish
    ])
  ];
}
