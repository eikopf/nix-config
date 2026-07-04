{
  config,
  pkgs,
  user,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./thunderbird.nix
  ];

  # systemd
  systemd.network.wait-online.enable = false;

  # networking
  networking.hostName = "wildspitz";
  networking.nftables.enable = true;

  services.tailscale.enable = true;

  networking.firewall = {
    trustedInterfaces = [ config.services.tailscale.interfaceName ];

    allowedTCPPorts = [
      8083 # calibre-web-automated (LAN: KOReader's userspace tailscaled can't originate tailnet connections)
    ];

    allowedUDPPorts = [
      config.services.tailscale.port
    ];
  };

  # Calibre-Web-Automated — containerised ebook server replacing the desktop
  # calibre content server. Runs rootful under podman (the nixpkgs default
  # backend; daemonless, and the podman module wires netavark up to nftables
  # automatically). The container starts as root and drops to PUID/PGID, so
  # everything it writes to the library and config mounts stays owned by
  # oliver:users. Published on all interfaces: tailnet access goes via
  # tailscale serve below, but the Kindle (KOReader) needs plain LAN access —
  # its tailscaled runs userspace-networking without proxy flags, which only
  # handles inbound connections. Auth is CWA's own login either way.
  virtualisation.podman.enable = true;
  virtualisation.oci-containers = {
    backend = "podman";
    containers.calibre-web-automated = {
      # Pinned release tag, registry-qualified so podman short-name
      # resolution can't misfire under systemd; bump deliberately.
      image = "docker.io/crocodilestick/calibre-web-automated:v4.0.6";
      environment = {
        PUID = "1000"; # oliver
        PGID = "100"; # users
        TZ = config.time.timeZone;
      };
      volumes = [
        "/var/lib/calibre-web-automated:/config" # app.db, CWA state
        "/home/oliver/documents/library-ingest:/cwa-book-ingest" # drop books here to auto-import
        "/home/oliver/documents/library:/calibre-library" # calibre library (metadata.db)
      ];
      ports = [ "8083:8083" ];
    };
  };

  # The container chowns these to PUID:PGID at startup, but they must exist
  # before podman can bind-mount them.
  systemd.tmpfiles.rules = [
    "d /var/lib/calibre-web-automated 0750 oliver users -"
    "d /home/oliver/documents/library-ingest 0755 oliver users -"
  ];

  # Serve Calibre-Web-Automated as a Tailscale Service: it gets its own DNS
  # name (https://calibre.<tailnet>.ts.net) and virtual IP, leaving Wildspitz's
  # hostname free for other services (one unit like this per service).
  # The tailnet-side half lives in the admin console: the svc:calibre
  # definition, host approval, and an ACL grant for access (port 443).
  # `serve --service` only runs in the background, so model it as a oneshot
  # whose stop action clears the service config again.
  systemd.services.tailscale-serve-calibre = {
    description = "Advertise Calibre-Web-Automated as Tailscale Service svc:calibre";
    after = [ "tailscaled.service" ];
    requires = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];
    # tailscaled's local API may not be ready right at boot; wait for it.
    preStart = "until ${config.services.tailscale.package}/bin/tailscale status --peers=false >/dev/null 2>&1; do sleep 1; done";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      # Straight to the container — unlike stock calibre, CWA tolerates the
      # empty Tailscale-User-* header values that serve injects, so no
      # sanitizing proxy is needed.
      ExecStart = "${config.services.tailscale.package}/bin/tailscale serve --service=svc:calibre --yes --https=443 127.0.0.1:8083";
      # Clears the whole service config, i.e. the port mapping above.
      ExecStop = "${config.services.tailscale.package}/bin/tailscale serve clear svc:calibre";
    };
  };

  boot.initrd.systemd.network.wait-online.enable = false;

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

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelParams = [ "video=DP-1:e" ];

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
  # gpg-agent (below) is the SSH agent; prevent gcr from competing for SSH_AUTH_SOCK.
  services.gnome.gcr-ssh-agent.enable = false;

  # xdg-desktop-portal — required for screen sharing, file pickers, and
  # PipeWire-based capture under Wayland
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  # Force native Wayland rendering to avoid blurriness from XWayland upscaling
  # under fractional scaling (DP-1 @ 1.5×).
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1"; # Firefox / Thunderbird
    ELECTRON_OZONE_PLATFORM_HINT = "auto"; # Electron 22+ apps
  };

  environment.systemPackages = with pkgs; [
    # Needed on PATH by sway keybindings
    swaylock
    grim
    slurp
    wl-clipboard
  ];

  # home-manager config
  home-manager.users.${user} = {
    imports = [
      ./sway.nix
      ./swayidle.nix
      ./waybar.nix
      ./rofi.nix
      ./desktop-theme.nix
    ];

    # disable programs not used on this host
    programs.kitty.enable = false;
    programs.neovide.enable = false;

    # enable programs specific to this host
    programs.anki.enable = true;
    programs.firefox.enable = true;
    programs.vscode.enable = true;

    # gpg-agent is the sole SSH agent on this host.
    # gcr is required for pinentry-gnome3 to work outside of a full GNOME session.
    home.packages = [ pkgs.gcr ];
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentry.package = pkgs.pinentry-gnome3;
    };
  };

  languages = {
    nix.enable = true;
    c.enable = true;
    javascript.enable = true;
    lean.enable = true;
    lua.enable = true;
    python.enable = true;
  };

  # release at first install — do not change
  system.stateVersion = "25.11";
}
