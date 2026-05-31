{ pkgs, ... }:
{
  programs.vscode = {
    enable = false; # enabled per-host; see e.g. hosts/wildspitz/default.nix
    profiles.default.extensions = with pkgs.vscode-extensions; [
      leanprover.lean4
    ];
  };
}
