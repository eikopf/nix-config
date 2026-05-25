{
  config,
  lib,
  pkgs,
  user,
  languages,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # networking
  networking.hostName = "wildspitz";

  # SSH server — allows logging in from other machines on the network
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false; # key-based auth only
      PermitRootLogin = "no";
    };
  };

  # latest kernel for better AMD hardware support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Early KMS: load amdgpu in the initrd so the driver owns the display
  # pipeline from the very start of boot, before simpledrm (EFI framebuffer)
  # takes over. Without this, amdgpu loads late, probes DP-1 while the monitor
  # is off, marks it disconnected, and never properly re-initialises it when the
  # monitor powers on later (the HPD event is silently dropped).
  # video=DP-1:e forces the output to stay enabled even when HPD reports no
  # display attached, so signal is present the moment the monitor comes on.
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelParams = [ "video=DP-1:e" ];

  # Sway (Wayland compositor)
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # graphics
  hardware.graphics.enable = true;

  # login manager
  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --asterisks --cmd sway";
        user = "greeter";
      };
    };
  };

  # xdg-desktop-portal — required for screen sharing, file pickers, and
  # PipeWire-based capture under Wayland
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  programs.firefox.enable = true;
  programs.thunderbird.enable = true;

  # Force native Wayland rendering to avoid blurriness from XWayland upscaling
  # under fractional scaling (DP-1 @ 1.5×).
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1"; # Firefox / Thunderbird
    ELECTRON_OZONE_PLATFORM_HINT = "auto"; # Electron 22+ apps
  };

  environment.systemPackages = with pkgs; [
    # Sway essentials
    swaylock
    swayidle
    foot
    rofi-power-menu
    grim
    slurp
    wl-clipboard
    waybar
  ];

  # home-manager config
  home-manager.users.${user} = {
    imports = [
      ./sway.nix
      ./swayidle.nix
      ./waybar.nix
      ./rofi.nix
    ];

    # cursor and GTK settings
    home.pointerCursor = {
      gtk.enable = true;
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
    };

    gtk = {
      enable = true;
      theme = {
        name = "adw-gtk3";
        package = pkgs.adw-gtk3;
      };
      iconTheme = {
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
      };
    };

    # swaybg wallpaper (as a service so sway config reloads don't kill it)
    systemd.user.services.swaybg = {
      Unit = {
        Description = "swaybg wallpaper";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.swaybg}/bin/swaybg -o DP-1 -i ${../../wallpaper/gris.jpg} -m fill";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    # create $XDG_PICTURES_DIR/screenshots — grim writes here
    systemd.user.tmpfiles.rules = [
      "d %h/pictures/screenshots 0755 - - -"
    ];

    # disable programs not used on this host
    programs.kitty.enable = lib.mkForce false;
    programs.neovide.enable = lib.mkForce false;

    # mako notification daemon
    services.mako = {
      enable = true;
      settings = {
        font = "Berkeley Mono 10";
        background-color = "#f5f5f5";
        text-color = "#303030";
        border-color = "#585858";
        border-size = 2;
        border-radius = 0;
        default-timeout = 5000;
      };
    };
  };

  enabledLanguages = with languages; [
    nix
    c
    javascript
  ];

  # minimum nix compat version
  system.stateVersion = "25.11";
}
