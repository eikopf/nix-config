
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports =
    [ # generated hardware configuration
      ./hardware-configuration.nix
    ];

  # nix garbage collection
  nix.gc = {
    automatic = true;
    randomizedDelaySec = "14m";
    options = "--delete-older-than 10d";
  };
  
  # user
  users.users.oliver = {
    home = /home/oliver;
    isNormalUser = true;
    shell = pkgs.fish;
    description = "Oliver Wooding";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # shell
  programs.fish.enable = true;
  
  # bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking
  networking.hostName = "rigi";
  networking.networkmanager.enable = true;

  # locale
  time.timeZone = "Europe/Zurich";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # X11
  services.xserver.enable = true;
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.variant = "mac";

  # Plasma 6
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # audio
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # graphics
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    open = true;
  };

  # install firefox
  programs.firefox.enable = true;

  # allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # environment variables
  environment.variables = (import ../../modules/env.nix);

  # minimum nix compat version
  system.stateVersion = "24.11";
}
