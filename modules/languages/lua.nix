# lua (+ fennel) language module

{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    fennel-ls
    (luajit.withPackages (
      ps: with ps; [
        fennel
        readline
      ]
    ))
  ];
}
