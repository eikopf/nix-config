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

  # bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking
  networking.hostName = "wildspitz";
  networking.networkmanager.enable = true;

  # Sway (Wayland compositor)
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # graphics
  hardware.graphics.enable = true;

  # install firefox
  programs.firefox.enable = true;

  # allow unfree packages
  nixpkgs.config.allowUnfree = true;

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
