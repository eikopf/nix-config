{ lib, ... }:
{
  programs.kitty = {
    enable = lib.mkDefault true;
    settings = {
      scrollback_lines = 10000;
      enable_audio_bell = false;
      update_check_interval = 0;
    };
  };
}
