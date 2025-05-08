# basic configuration for all macOS hosts

{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    emacs-macport
    skhd
    yabai
  ];

  security.pam.enableSudoTouchIdAuth = true;

  system.defaults = {
    dock.autohide = true;
    dock.mru-spaces = false;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv"; # use columns in Finder by default
    NSGlobalDomain.AppleICUForce24HourTime = true;
    NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
  };
}
