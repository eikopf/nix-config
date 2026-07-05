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
      6060 # grimmory (LAN: KOReader's userspace tailscaled can't originate tailnet connections)
    ];

    allowedUDPPorts = [
      config.services.tailscale.port
    ];
  };

  # Grimmory — containerised ebook server replacing Calibre-Web-Automated.
  # Chosen because it issues restricted per-device credentials: OPDS users
  # (browse/download) and KOReader sync credentials (reading progress) are
  # separate credential pairs scoped to the parent account, so the Kindle
  # never holds the main login. It's a Java app backed by MariaDB, so the one
  # CWA container becomes two, joined by a dedicated podman network (the
  # default network has no inter-container DNS). Runs rootful under podman
  # (the nixpkgs default backend; daemonless, and the podman module wires
  # netavark up to nftables automatically); both images drop to the given
  # UID/GID, so everything written to the mounts stays owned by oliver:users.
  # Grimmory indexes the calibre library in place — books stay where they
  # are, metadata comes from calibre's metadata.opf sidecars, and metadata.db
  # is simply inert.
  #
  # Published on all interfaces: tailnet access goes via tailscale serve
  # below, but the Kindle (KOReader) needs plain LAN access — its tailscaled
  # runs userspace-networking without proxy flags, which only handles inbound
  # connections.
  #
  # One imperative step: both containers read DB credentials from
  # /var/lib/grimmory/secrets.env (root-owned, outside the store), containing
  # MYSQL_ROOT_PASSWORD, and MYSQL_PASSWORD = DATABASE_PASSWORD. The units
  # restart until it exists.
  virtualisation.podman.enable = true;
  virtualisation.oci-containers = {
    backend = "podman";

    # Pinned release tags, registry-qualified so podman short-name
    # resolution can't misfire under systemd; bump deliberately.
    containers.grimmory = {
      image = "ghcr.io/grimmory-tools/grimmory:v3.2.4";
      environment = {
        USER_ID = "1000"; # oliver
        GROUP_ID = "100"; # users
        TZ = config.time.timeZone;
        DATABASE_URL = "jdbc:mariadb://grimmory-mariadb:3306/grimmory";
        DATABASE_USERNAME = "grimmory";
      };
      environmentFiles = [ "/var/lib/grimmory/secrets.env" ]; # DATABASE_PASSWORD
      volumes = [
        "/var/lib/grimmory/data:/app/data" # app state, cache, logs
        "/home/oliver/documents/library:/books" # library, indexed in place
        "/home/oliver/documents/library-ingest:/bookdrop" # drop books here to auto-import
      ];
      ports = [ "6060:6060" ];
      networks = [ "grimmory" ];
      # Ordering only — no health gating, but Restart=always rides out
      # MariaDB's first-boot initialisation.
      dependsOn = [ "grimmory-mariadb" ];
    };

    containers.grimmory-mariadb = {
      # The linuxserver image (as in Grimmory's reference compose) for its
      # PUID/PGID handling, keeping the data dir owned by oliver:users.
      image = "lscr.io/linuxserver/mariadb:11.4.5";
      environment = {
        PUID = "1000"; # oliver
        PGID = "100"; # users
        TZ = config.time.timeZone;
        MYSQL_DATABASE = "grimmory";
        MYSQL_USER = "grimmory";
      };
      environmentFiles = [ "/var/lib/grimmory/secrets.env" ]; # MYSQL_{ROOT_,}PASSWORD
      volumes = [ "/var/lib/grimmory/mariadb:/config" ];
      # No published ports: only reachable over the grimmory podman network.
      networks = [ "grimmory" ];
    };
  };

  # The oci-containers `networks` option only passes --network; the network
  # itself has to be created out of band.
  systemd.services.podman-network-grimmory = {
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${config.virtualisation.podman.package}/bin/podman network create --ignore grimmory";
    };
    requiredBy = [
      "podman-grimmory.service"
      "podman-grimmory-mariadb.service"
    ];
    before = [
      "podman-grimmory.service"
      "podman-grimmory-mariadb.service"
    ];
  };

  # The containers chown these to the configured UID:GID at startup, but they
  # must exist before podman can bind-mount them.
  systemd.tmpfiles.rules = [
    "d /var/lib/grimmory 0750 root users -" # also holds secrets.env (0600 root)
    "d /var/lib/grimmory/data 0750 oliver users -"
    "d /var/lib/grimmory/mariadb 0750 oliver users -"
    "d /home/oliver/documents/library-ingest 0755 oliver users -"
  ];

  # Serve Grimmory as a Tailscale Service: it gets its own DNS name
  # (https://grimmory.<tailnet>.ts.net) and virtual IP, leaving Wildspitz's
  # hostname free for other services (one unit like this per service).
  # The tailnet-side half lives in the admin console: the svc:grimmory
  # definition, host approval, and an ACL grant for access (port 443).
  # `serve --service` only runs in the background, so model it as a oneshot
  # whose stop action clears the service config again.
  systemd.services.tailscale-serve-grimmory = {
    description = "Advertise Grimmory as Tailscale Service svc:grimmory";
    after = [ "tailscaled.service" ];
    requires = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];
    # tailscaled's local API may not be ready right at boot; wait for it.
    preStart = "until ${config.services.tailscale.package}/bin/tailscale status --peers=false >/dev/null 2>&1; do sleep 1; done";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${config.services.tailscale.package}/bin/tailscale serve --service=svc:grimmory --yes --https=443 127.0.0.1:6060";
      # Clears the whole service config, i.e. the port mapping above.
      ExecStop = "${config.services.tailscale.package}/bin/tailscale serve clear svc:grimmory";
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
