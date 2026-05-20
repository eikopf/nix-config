{ ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/boot".options = [ "umask=0077" ];

  networking.networkmanager.enable = true;

  nixpkgs.config.allowUnfree = true;
}
