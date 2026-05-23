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
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd sway";
        user = "greeter";
      };
    };
  };

  # install firefox
  programs.firefox.enable = true;

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

    gtk.enable = true;

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
