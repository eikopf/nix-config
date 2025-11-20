{ pkgs, lib, ... }@inputs:
{
  imports = [
    ./nix.nix
    ./shell.nix
    ./users.nix
  ];

  environment.systemPackages = lib.mkMerge [
    (import ./nix.nix inputs).environment.systemPackages
    (import ./shell.nix inputs).environment.systemPackages

    # base packages installed by all hosts
    (with pkgs; [
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
    ])
  ];
}
