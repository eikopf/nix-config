{
  config,
  lib,
  pkgs,
  user,
  languages,
  ...
}:
let
  # Thunderbird creates an empty ~/Thunderbird directory on every startup (a
  # side-effect of it initialising its default profile-root path), even though
  # all real data lives in ~/.thunderbird.  This wrapper runs the real binary
  # and then removes the empty directory once Thunderbird exits, keeping ~ tidy.
  thunderbird = pkgs.symlinkJoin {
    name = "thunderbird";
    paths = [ pkgs.thunderbird ];
    postBuild =
      let
        script = pkgs.writeShellScript "thunderbird" ''
          ${lib.getExe pkgs.thunderbird} "$@"
          _status=$?
          rmdir "$HOME/Thunderbird" "$HOME/thunderbird" 2>/dev/null || true
          exit "$_status"
        '';
      in
      ''
        rm "$out/bin/thunderbird"
        ln -s ${script} "$out/bin/thunderbird"
      '';
  };
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  # networking
  networking.hostName = "wildspitz";

  # exposed ports
  networking.firewall.allowedTCPPorts = [
    8080 # calibre content server
    9090 # calibre wireless device connection
  ];

  # Prefer wired over WiFi: disable WiFi radio when any ethernet link comes up,
  # re-enable it if ethernet goes down so we're never left without connectivity.
  # A dispatcher script is required here because NetworkManager has no native
  # declarative option for this — ipv4.never-default is per-connection rather
  # than per-device, and the equivalent behaviour in GNOME (which does have it
  # built-in) is itself implemented on top of the same dispatcher mechanism.
  networking.networkmanager.dispatcherScripts = [
    {
      source = pkgs.writeShellScript "wifi-auto-toggle" ''
        DEVICE_TYPE=$(${pkgs.networkmanager}/bin/nmcli -t -f GENERAL.TYPE device show "$1" 2>/dev/null | cut -d: -f2)
        [ "$DEVICE_TYPE" = "ethernet" ] || exit 0
        case "$2" in
          up)   ${pkgs.networkmanager}/bin/nmcli radio wifi off ;;
          down) ${pkgs.networkmanager}/bin/nmcli radio wifi on  ;;
        esac
      '';
      type = "basic";
    }
  ];

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

  # keychain — needed for VSCode (and other apps) to store secrets securely.
  # PAM integration ensures the keyring is unlocked automatically on login.
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  # xdg-desktop-portal — required for screen sharing, file pickers, and
  # PipeWire-based capture under Wayland
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  programs.firefox.enable = true;

  # Force native Wayland rendering to avoid blurriness from XWayland upscaling
  # under fractional scaling (DP-1 @ 1.5×).
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1"; # Firefox / Thunderbird
    ELECTRON_OZONE_PLATFORM_HINT = "auto"; # Electron 22+ apps
  };

  # Syncthing — keeps the Calibre library in sync with Pilatus
  services.syncthing = {
    enable = true;
    user = "oliver";
    dataDir = "/home/oliver";
    openDefaultPorts = true; # 22000/tcp (sync) + 21027/udp (discovery)
  };

  environment.systemPackages = with pkgs; [
    thunderbird # wrapped to suppress the spurious ~/Thunderbird directory
    calibre # ebook manager (library synced with Pilatus via Syncthing)

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

    # disable programs not used on this host
    programs.kitty.enable = lib.mkForce false;
    programs.neovide.enable = lib.mkForce false;

    # enable programs specific to this host
    programs.vscode.enable = lib.mkForce true;

    # gpg-agent, also acting as the SSH agent.
    # gcr is required for pinentry-gnome3 to work outside of a full GNOME session.
    home.packages = [ pkgs.gcr ];
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentry.package = pkgs.pinentry-gnome3;
    };

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
    lean
  ];

  # minimum nix compat version
  system.stateVersion = "25.11";
}
