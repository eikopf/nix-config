# basic configuration for all macOS hosts

{
  user,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    aerospace
  ];

  security.pam.services.sudo_local.touchIdAuth = true;

  # this is apparently necessary for an ongoing migration, and will be
  # removed at some later point
  system.primaryUser = user;

  system.defaults = {
    dock.autohide = true;
    dock.mru-spaces = false;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv"; # use columns in Finder by default
    NSGlobalDomain.AppleICUForce24HourTime = true;
    NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
  };
}
