# rust language module

{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ rustup ];
}
