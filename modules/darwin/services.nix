# macOS services

{
  lib,
  ...
}:
{
  services.nix-daemon.enable = true;

  # skhd
  services.skhd = {
    enable = true;

    skhdConfig = lib.strings.concatLines [
      # shortcuts to open ghostty and neovide
      "cmd - return : open -a /Applications/Ghostty.app"
      "cmd + shift - return : neovide"

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
    enable = true;

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
      "yabai -m rule --add app='^Archive Utility$' manage=off"
      "yabai -m rule --add app='^Raycast' manage=off"
    ];
  };
}
