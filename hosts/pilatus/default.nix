{
  self,
  pkgs,
  ...
}:
{
  imports = [
    ../../modules/languages/chez.nix
    ../../modules/languages/haskell.nix
    ../../modules/languages/janet.nix
    ../../modules/languages/java.nix
    ../../modules/languages/javascript.nix
    ../../modules/languages/lean.nix
    ../../modules/languages/lua.nix
    ../../modules/languages/ocaml.nix
    ../../modules/languages/python.nix
    ../../modules/languages/racket.nix
    ../../modules/languages/rust.nix
    ../../modules/darwin
  ];

  environment.systemPackages = with pkgs; [ ];

  # set git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
