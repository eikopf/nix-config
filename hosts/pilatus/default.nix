{
  self,
  languages,
  ...
}:
{
  imports = [
    ../../modules/darwin
  ];

  users.users.oliver.home = "/Users/oliver";

  enabledLanguages = with languages; [
    chez
    haskell
    idris
    janet
    java
    javascript
    lean
    lua
    ocaml
    python
    racket
    rust
  ];

  # set git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
