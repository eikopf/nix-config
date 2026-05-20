# user configuration for both NixOS and macOS hosts

{ user, pkgs, lib, ... }:
let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in
{
  users.users.${user} =
    {
      description = "Oliver Wooding";
      home = if isDarwin then /Users/${user} else /home/${user};
      shell = pkgs.fish;
    }
    // lib.optionalAttrs isLinux {
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
      isNormalUser = true;
    };
}
