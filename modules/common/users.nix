# user configuration for both NixOS and macOS hosts

{ pkgs, lib, ... }:
let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in
{
  users.users.oliver =
    {
      description = "Oliver Wooding";
      home = if isDarwin then /Users/oliver else /home/oliver;
      shell = pkgs.fish;

    }
    # these keys only exist on linux hosts
    // lib.mkIf isLinux {
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
      isNormalUser = true;
    };
}
