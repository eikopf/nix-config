{
  config,
  pkgs,
  languages,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking
  networking.hostName = "wildspitz";

  # Sway (Wayland compositor)
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # graphics
  hardware.graphics.enable = true;

  # install firefox
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    # Sway essentials
    swaylock
    swayidle
    foot # Wayland-native terminal
    wmenu # Wayland-native dmenu replacement
    mako # notification daemon
    grim # screenshot
    slurp # region selection
    wl-clipboard
  ];

  enabledLanguages = with languages; [
    nix
  ];

  # minimum nix compat version
  system.stateVersion = "25.11";
}
