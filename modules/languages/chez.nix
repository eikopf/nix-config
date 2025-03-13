# chezscheme language module

{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.chez ];

  environment.variables = {
    CHEZSCHEMELIBDIRS = "$HOME/.local/lib/scheme:";
    CHEZSCHEMELIBEXTS = ".scm::.so:";
  };
}
