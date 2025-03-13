# janet language module

{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ janet ];
}
