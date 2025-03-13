# racket language module

{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ racket-minimal ];
}
