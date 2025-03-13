# user configuration for both NixOS and macOS hosts

{ pkgs, lib, ... }:
let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in
{
  users.users.oliver = {
    description = "Oliver Wooding";
    home = if isDarwin then /Users/oliver else /home/oliver;
    shell = pkgs.fish;

    extraGroups =
      if isDarwin then
        [
          "staff"
          "admin"
        ]
      else
        [
          "networkmanager"
          "wheel"
        ];

    # this key is only valid for NixOS hosts, so we
    # use `lib.mkIf` to conditionally include it
    isNormalUser = lib.mkIf isLinux true;
  };
}
