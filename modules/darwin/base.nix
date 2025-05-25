# basic configuration for all macOS hosts

{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    skhd
    yabai
  ];

  security.pam.services.sudo_local.touchIdAuth = true;

  # this is apparently necessary for an ongoing migration, and will be
  # removed at some later point
  system.primaryUser = "oliver";

  system.defaults = {
    dock.autohide = true;
    dock.mru-spaces = false;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv"; # use columns in Finder by default
    NSGlobalDomain.AppleICUForce24HourTime = true;
    NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
  };
}
