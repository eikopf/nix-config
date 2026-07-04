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
  systemd.services.tailscaled.serviceConfig.Environment = [
    "TS_DEBUG_FIREWALL_MODE=nftables"
  ];

  # networking
  networking.hostName = "wildspitz";
  networking.nftables.enable = true;

  networking.firewall = {
    trustedInterfaces = [ config.services.tailscale.interfaceName ];

    allowedTCPPorts = [
      8080 # calibre content server
      9090 # calibre wireless device server
    ];

    allowedUDPPorts = [
      54982 # calibre wireless device discovery (KOReader broadcasts here to find the server)
      config.services.tailscale.port
    ];
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

  # Syncthing — keeps the Calibre library in sync with Pilatus
  services.syncthing = {
    enable = true;
    user = "oliver";
    dataDir = "/home/oliver";
    openDefaultPorts = true; # 22000/tcp (sync) + 21027/udp (discovery)
  };

  environment.systemPackages = with pkgs; [
    calibre # ebook manager (library synced with Pilatus via Syncthing)

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
