# lean language module

{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ elan ];
}
