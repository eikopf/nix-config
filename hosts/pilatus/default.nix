{
  self,
  languages,
  ...
}:
{
  # required by home-manager
  users.users.oliver.home = "/Users/oliver";

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

  # disable nix-darwin daemon in favour of using
  # the determinate-nix daemon
  services.nix-daemon.enable = false;

  # nix-darwin trivia
  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 5;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
