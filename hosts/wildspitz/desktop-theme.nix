# Desktop theming and visual environment for wildspitz.
# Covers: cursor + GTK theme, swaybg wallpaper service, screenshots directory,
# and the mako notification daemon.  Host-level policy (which programs are
# enabled/disabled, gpg-agent config) stays in default.nix; this file is purely
# about the look-and-feel of the desktop session.
{
  pkgs,
  ...
}:
{
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
    gtk4.theme = null;
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
}
