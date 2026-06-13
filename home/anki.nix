{ lib, ... }:
{
  programs.anki = {
    enable = lib.mkDefault false;
  };
}
