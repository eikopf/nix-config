{
  self,
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # give home-manager the home directory path
  users.users.oliver.home = "/Users/oliver";

  # shell
  environment.variables = (import ../../modules/env.nix);
  environment.shells = [ pkgs.fish pkgs.zsh ];
  environment.shellAliases = (import ../../modules/aliases.nix);
  programs.fish.enable = true;
  users.users.oliver.shell = pkgs.fish;

  # nix
  services.nix-daemon.enable = true;
  nix.settings.experimental-features = "nix-command flakes";

  # macOS config
  security.pam.enableSudoTouchIdAuth = true;
  system.defaults = {
    dock.autohide = true;
    dock.mru-spaces = false;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";   # use columns in Finder by default
    NSGlobalDomain.AppleICUForce24HourTime = true;
    NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
  };

  # set git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
