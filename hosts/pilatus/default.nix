{
  self,
  pkgs,
  languages,
  ...
}:
{
  users.knownUsers = [ "oliver" ];

  users.users.oliver = {
    # required by home-manager
    home = "/Users/oliver";
    shell = pkgs.fish;
    # this is apparently the default uid for the primary user on macOS, but you
    # can get the exact value by running `dscl . -read /Users/<user> UniqueID`
    uid = 501;
  };

  networking = {
    computerName = "Pilatus";
    hostName = "pilatus";
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  homebrew = {
    enable = true;
    global.autoUpdate = false;

    casks = [
      "ghostty"
    ];
  };

  enabledLanguages = with languages; [
    chez
    haskell
    idris2
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

  # nix-darwin trivia
  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 5;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
