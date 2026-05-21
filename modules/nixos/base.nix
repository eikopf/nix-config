{ ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/boot".options = [ "umask=0077" ];

  networking.networkmanager.enable = true;

  # allow regular users to mount removable drives
  services.udisks2.enable = true;

  nixpkgs.config.allowUnfree = true;
}
