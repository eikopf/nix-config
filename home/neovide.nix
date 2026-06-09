{ lib, ... }:
{
  programs.neovide = {
    enable = lib.mkDefault true;
    settings = {
      frame = "transparent";
      font = {
        normal = "BerkeleyMono Nerd Font";
        size = 15.0;
      };
    };
  };
}
