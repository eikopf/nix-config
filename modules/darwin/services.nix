# macOS services

{
  lib,
  ...
}:
{
  # aerospace
  services.aerospace = {
    enable = true;

    settings = {
      # layout
      gaps = {
        outer.top = 8;
        outer.bottom = 8;
        outer.left = 8;
        outer.right = 8;

        inner.horizontal = 8;
        inner.vertical = 8;
      };

      # primary keybindings
      mode.main.binding = {
        alt-slash = "layout tiles horizontal vertical";
        alt-comma = "layout accordion horizontal vertical";

        alt-h = "focus left";
        alt-j = "focus down";
        alt-k = "focus up";
        alt-l = "focus right";

        alt-shift-h = "move left";
        alt-shift-j = "move down";
        alt-shift-k = "move up";
        alt-shift-l = "move right";

        ctrl-alt-shift-h = "move-node-to-monitor --focus-follows-window left";
        ctrl-alt-shift-l = "move-node-to-monitor --focus-follows-window right";

        alt-minus = "resize smart -50";
        alt-equal = "resize smart +50";

        alt-shift-semicolon = "mode service";
      };

      # service mode keybindings
      mode.service.binding = lib.mapAttrs (_: v: [ v ] ++ [ "mode main" ]) {
        esc = "reload-config";
        r = "flatten-workspace-tree"; # reset layout
        f = "layout floating tiling"; # toggle between floating and tiling layout
        backspace = "close-all-windows-but-current";
      };
    };
  };

  # skhd
  services.skhd = {
    enable = false;

    skhdConfig = lib.strings.concatLines [
      # move focus between windows in the current display
      "alt - h : yabai -m window --focus west"
      "alt - j : yabai -m window --focus south"
      "alt - k : yabai -m window --focus north"
      "alt - l : yabai -m window --focus east"

      # swap windows directionally
      "shift + alt - h : yabai -m window --swap west"
      "shift + alt - j : yabai -m window --swap south"
      "shift + alt - k : yabai -m window --swap north"
      "shift + alt - l : yabai -m window --swap east"

      # move windows directionally
      "ctrl + alt - h : yabai -m window --warp west"
      "ctrl + alt - j : yabai -m window --warp south"
      "ctrl + alt - k : yabai -m window --warp north"
      "ctrl + alt - l : yabai -m window --warp east"

      # move focus between spaces (requires disabling SIP)
      "alt - 1 : yabai -m space --focus 1"
      "alt - 2 : yabai -m space --focus 2"
      "alt - 3 : yabai -m space --focus 3"
      "alt - 4 : yabai -m space --focus 4"
      "alt - 5 : yabai -m space --focus 5"
      "alt - 6 : yabai -m space --focus 6"
      "alt - 7 : yabai -m space --focus 7"
      "alt - 8 : yabai -m space --focus 8"
      "alt - 9 : yabai -m space --focus 9"
      "alt - 0 : yabai -m space --focus 0"

      # send focused window to a space
      "shift + alt - 1 : yabai -m window --space 1"
      "shift + alt - 2 : yabai -m window --space 2"
      "shift + alt - 3 : yabai -m window --space 3"
      "shift + alt - 4 : yabai -m window --space 4"
      "shift + alt - 5 : yabai -m window --space 5"
      "shift + alt - 6 : yabai -m window --space 6"
      "shift + alt - 7 : yabai -m window --space 7"
      "shift + alt - 8 : yabai -m window --space 8"
      "shift + alt - 9 : yabai -m window --space 9"
      "shift + alt - 0 : yabai -m window --space 0"

      # rotate tree
      "alt - r : yabai -m space --rotate 90"

      # mirror tree vertically
      "alt - y : yabai -m space --mirror y-axis"

      # toggle window padding and gap in current space
      "alt - a : yabai -m space --toggle padding; yabai -m space --toggle gap"

      # change layout in current space
      "ctrl + alt - a : yabai -m space --layout bsp" # (activate)
      "ctrl + alt - d : yabai -m space --layout float" # (deactivate)
    ];
  };

  # yabai
  services.yabai = {
    enable = false;

    config =
      let
        padding = 8;
      in
      {
        # mouse
        mouse_modifier = "fn";
        mouse_follows_focus = "off";
        focus_follows_mouse = "off";

        # layout
        layout = "bsp";
        top_padding = padding;
        bottom_padding = padding;
        left_padding = padding;
        right_padding = padding;
        window_gap = padding;
        window_placement = "second_child";
        window_insertion_point = "focused";
      };

    extraConfig = lib.strings.concatLines [
      # ignored apps
      "yabai -m rule --add app='^System Settings$' manage=off"
      "yabai -m rule --add app='^Discord$' manage=off"
      "yabai -m rule --add app='^Music$' manage=off"
      "yabai -m rule --add app='^Archive Utility$' manage=off"
      "yabai -m rule --add app='^Raycast' manage=off"
    ];
  };
}
