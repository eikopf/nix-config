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
      "cmd - return: open -a /Applications/Ghostty.app"
      "cmd + shift - return: neovide"
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
      };

    extraConfig = "yabai -m rule --add app='^System Settings$' manage=off";
  };
}
