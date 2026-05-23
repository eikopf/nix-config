{
  config,
  pkgs,
  user,
  languages,
  ...
}:
let
  modifier = "Mod4";
  gaps = { inner = 10; outer = 5; };
  # Sway places windows at (outer + inner) px from the screen edge,
  # because the inner gap applies to outer edges too. Verified empirically:
  # windows sit at x=15 with outer=5 and inner=10.
  edgeGap = gaps.outer + gaps.inner;
in
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

  # Sway config (via home-manager)
  home-manager.users.${user} = {
    wayland.windowManager.sway = {
      enable = true;
      config = {
        inherit modifier;
        terminal = "ghostty";
        menu = "rofi -show drun";

        fonts = {
          names = [ "Berkeley Mono" ];
          style = "Medium";
          size = 10.0;
        };

        output = {
          "DP-1" = {
            scale = "1.5";
          };
        };

        input = {
          "type:keyboard" = {
            xkb_options = "ctrl:nocaps";
          };
        };

        gaps = {
          inherit (gaps) inner outer;
        };

        window = {
          border = 2;
          titlebar = false;
        };

        floating = {
          border = 2;
          titlebar = false;
          modifier = modifier;
        };

        focus.followMouse = false;

        colors = {
          focused = {
            border = "#585858";
            background = "#585858";
            text = "#ffffff";
            indicator = "#585858";
            childBorder = "#585858";
          };
          unfocused = {
            border = "#cecece";
            background = "#cecece";
            text = "#585858";
            indicator = "#cecece";
            childBorder = "#cecece";
          };
          focusedInactive = {
            border = "#cecece";
            background = "#cecece";
            text = "#585858";
            indicator = "#cecece";
            childBorder = "#cecece";
          };
          urgent = {
            border = "#cecece";
            background = "#cecece";
            text = "#585858";
            indicator = "#cecece";
            childBorder = "#cecece";
          };
        };

        keybindings = {
          # terminal and launcher
          "${modifier}+Return" = "exec ghostty";
          "${modifier}+space" = "exec rofi -show drun";
          "${modifier}+Shift+q" = "kill";

          # focus (vim-style)
          "${modifier}+h" = "focus left";
          "${modifier}+j" = "focus down";
          "${modifier}+k" = "focus up";
          "${modifier}+l" = "focus right";
          "${modifier}+Left" = "focus left";
          "${modifier}+Down" = "focus down";
          "${modifier}+Up" = "focus up";
          "${modifier}+Right" = "focus right";

          # move windows
          "${modifier}+Shift+h" = "move left";
          "${modifier}+Shift+j" = "move down";
          "${modifier}+Shift+k" = "move up";
          "${modifier}+Shift+l" = "move right";
          "${modifier}+Shift+Left" = "move left";
          "${modifier}+Shift+Down" = "move down";
          "${modifier}+Shift+Up" = "move up";
          "${modifier}+Shift+Right" = "move right";

          # splits
          "${modifier}+Shift+s" = "split h";
          "${modifier}+Shift+v" = "split v";

          # layout
          "${modifier}+f" = "fullscreen toggle";
          "${modifier}+s" = "layout stacking";
          "${modifier}+w" = "layout tabbed";
          "${modifier}+e" = "layout toggle split";
          "${modifier}+Shift+t" = "floating toggle";
          "${modifier}+t" = "focus mode_toggle";
          "${modifier}+a" = "focus parent";

          # workspaces
          "${modifier}+1" = "workspace number 1";
          "${modifier}+2" = "workspace number 2";
          "${modifier}+3" = "workspace number 3";
          "${modifier}+4" = "workspace number 4";
          "${modifier}+5" = "workspace number 5";
          "${modifier}+6" = "workspace number 6";
          "${modifier}+7" = "workspace number 7";
          "${modifier}+8" = "workspace number 8";
          "${modifier}+9" = "workspace number 9";
          "${modifier}+0" = "workspace number 10";
          "${modifier}+Shift+1" = "move container to workspace number 1";
          "${modifier}+Shift+2" = "move container to workspace number 2";
          "${modifier}+Shift+3" = "move container to workspace number 3";
          "${modifier}+Shift+4" = "move container to workspace number 4";
          "${modifier}+Shift+5" = "move container to workspace number 5";
          "${modifier}+Shift+6" = "move container to workspace number 6";
          "${modifier}+Shift+7" = "move container to workspace number 7";
          "${modifier}+Shift+8" = "move container to workspace number 8";
          "${modifier}+Shift+9" = "move container to workspace number 9";
          "${modifier}+Shift+0" = "move container to workspace number 10";

          # screenshots (grim + slurp)
          "${modifier}+Ctrl+3" = "exec grim ~/screenshots/$(date +%F-%H-%M-%S).png";
          "${modifier}+Ctrl+4" = "exec grim -g \"$(slurp)\" ~/screenshots/$(date +%F-%H-%M-%S).png";

          # volume
          "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +10%";
          "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -10%";
          "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
          "XF86AudioMicMute" = "exec pactl set-source-mute @DEFAULT_SOURCE@ toggle";

          # lock screen
          "${modifier}+Ctrl+l" = "exec swaylock -c 000000";

          # sway management
          "${modifier}+Shift+c" = "reload";
          "${modifier}+Shift+e" = "exec rofi -show power-menu -modi \"power-menu:${pkgs.rofi-power-menu}/bin/rofi-power-menu --no-symbols\"";
          "${modifier}+Shift+b" = "exec systemctl --user is-active --quiet waybar && systemctl --user stop waybar || systemctl --user start waybar";
          "${modifier}+r" = "mode resize";
        };

        modes = {
          resize = {
            "h" = "resize shrink width 10 px";
            "j" = "resize grow height 10 px";
            "k" = "resize shrink height 10 px";
            "l" = "resize grow width 10 px";
            "Left" = "resize shrink width 10 px";
            "Down" = "resize grow height 10 px";
            "Up" = "resize shrink height 10 px";
            "Right" = "resize grow width 10 px";
            "Return" = "mode default";
            "Escape" = "mode default";
            "${modifier}+r" = "mode default";
          };
        };

        seat = {
          "*" = {
            xcursor_theme = "Adwaita 24";
          };
        };

        bars = [];

        startup = [
          { command = "swaymsg workspace number 1"; }
        ];
      };
    };

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

    # rofi launcher
    programs.rofi = {
      enable = true;
      theme = "alabaster";
    };

    xdg.dataFile."rofi/themes/alabaster.rasi".text = ''
      * {
          background-color: #f5f5f5;
          text-color:       #303030;
          border-color:     #585858;
          font:             "Berkeley Mono 10";
          padding:          0;
          margin:           0;
          spacing:          0;
      }

      window {
          border:  2px;
          padding: 8px;
          width:   40%;
      }

      inputbar {
          spacing:      6px;
          padding:      0 0 6px 0;
          children:     [prompt, entry];
          border:       0 0 1px 0;
          border-color: #cecece;
      }

      listview {
          padding:   4px 0 0 0;
          scrollbar: false;
      }

      element {
          padding:      4px 6px;
          spacing:      6px;
          border:       0 0 1px 0;
          border-color: #cecece;
      }

      element selected {
          background-color: #585858;
          text-color:       #ffffff;
          border-color:     #585858;
      }

      element-text {
          background-color: transparent;
          text-color:       inherit;
      }

      element-icon {
          background-color: transparent;
          size:             1em;
      }
    '';

    # disable programs not used on this host
    programs.kitty.enable = false;
    programs.neovide.enable = false;

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

    # waybar (run as a systemd user service so it starts/restarts on rebuild)
    systemd.user.services.waybar = {
      Unit = {
        Description = "Waybar";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.waybar}/bin/waybar";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
    programs.waybar = {
      enable = true;
      settings = [
        {
          layer = "top";
          position = "top";
          height = 28;
          spacing = 0;
          modules-left = [ "sway/workspaces" ];
          modules-right = [ "memory" "clock#date" "clock#time" ];

          "sway/workspaces" = {
            disable-scroll = true;
          };

          memory = {
            format = "<b>MEM</b> {}%";
            interval = 5;
          };

          "clock#date" = {
            format = "<b>DATE</b> {:%Y-%m-%d}";
            interval = 60;
          };

          "clock#time" = {
            format = "<b>TIME</b> {:%H:%M %Z}";
            interval = 5;
          };
        }
      ];
      style = ''
        * {
          font-family: Berkeley Mono;
          font-weight: 500;
          font-size: 10pt;
          border: none;
          border-radius: 0;
          min-height: 0;
          margin: 0;
          padding: 0;
        }

        window#waybar {
          background-color: #f5f5f5;
          color: #303030;
        }

        /* Left outer spacing: #workspaces confirmed to produce visible margin */
        #workspaces {
          margin-left: ${toString edgeGap}px;
        }

        /* Right outer spacing: .modules-right padding-right confirmed to affect right edge */
        .modules-right {
          padding-right: ${toString edgeGap}px;
        }

        /* Inter-module spacing on the right */
        .modules-right label {
          margin-left: 15px;
        }

        #workspaces button {
          padding: 0 6px;
          color: #585858;
          background-color: transparent;
        }

        #workspaces button.focused {
          color: #ffffff;
          background-color: #585858;
        }

        #workspaces button.urgent {
          color: #303030;
          background-color: #cecece;
        }
      '';
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
