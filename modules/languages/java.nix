# java language module

{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ zulu23 ];
}
