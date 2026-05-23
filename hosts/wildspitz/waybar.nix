{ pkgs, ... }:
let
  gaps = {
    inner = 10;
    outer = 5;
  };
  # Keep in sync with sway.nix — edgeGap aligns waybar with window edges
  edgeGap = gaps.outer + gaps.inner;
in
{
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
        modules-right = [
          "memory"
          "clock#date"
          "clock#time"
        ];

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
}
