{
  self,
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  # give home-manager the home directory path
  users.users.oliver.home = "/Users/oliver";

  # add main user to trusted users
  nix.settings.trusted-users = [
    "root"
    "oliver"
  ];

  # packages
  environment.systemPackages =
    (import ../../modules/packages.nix pkgs) ++ (import ./extra-packages.nix pkgs);

  # shell
  environment.variables = (import ../../modules/env.nix);
  environment.shells = [
    pkgs.fish
    pkgs.zsh
  ];
  environment.shellAliases = (import ../../modules/aliases.nix);
  programs.fish.enable = true;
  users.users.oliver.shell = pkgs.fish;

  # nix
  services.nix-daemon.enable = true;
  nix.settings.experimental-features = "nix-command flakes";

  # skhd
  services.skhd = {
    enable = true;

    skhdConfig = lib.strings.concatLines [
      "cmd - return: /Applications/Ghostty.app/Contents/MacOS/ghostty"
      "cmd + shift - return: neovide"
    ];
  };

  # yabai
  services.yabai = {
    enable = true;

    config =
      let
        padding = 8;
      in
      {
        # mouse
        mouse_modifier = "fn";
        mouse_follows_focus = "off";
        focus_follows_mouse = "off";

        # layout
        layout = "bsp";
        top_padding = padding;
        bottom_padding = padding;
        left_padding = padding;
        right_padding = padding;
        window_gap = padding;
      };

    extraConfig = "yabai -m rule --add app='^System Settings$' manage=off";
  };

  # macOS config
  security.pam.enableSudoTouchIdAuth = true;
  system.defaults = {
    dock.autohide = true;
    dock.mru-spaces = false;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv"; # use columns in Finder by default
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
