{
  user,
  pkgs,
  languages,
  ...
}:
{
  networking = {
    computerName = "Pilatus";
    hostName = "pilatus";
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  # define the installed nix package on this host; some tools like nixd rely
  # on this setting being accurate to work correctly
  nix.package = pkgs.lix;

  homebrew = {
    enable = true;
    global.autoUpdate = false;

    casks = [
      # coding agents
      "claude-code"
      "codex"

      "calibre" # ebook manager
      "ghostty" # terminal
    ];
  };

  environment.systemPackages = with pkgs; [
    # embedded ESP tooling
    ccache # compiler cache for c/c++
    cmake # c build system
    dfu-util # device firmware update USB programmer
    espup # ESP tooling manager
    ldproxy # proxy linker
    ninja # alternative c build system

    qemu # emulator

    # docker tooling
    docker

    gh # github CLI integration
    tmux # terminal multiplexer
    pnpm # javascript package manager

    # macos utilities
    monitorcontrol # external display controller
  ];

  enabledLanguages = with languages; [
    c
    chez
    haskell
    hledger
    idris2
    janet
    java
    javascript
    lean
    lua
    markdown
    nix
    ocaml
    python
    # racket
    rust
    typst
  ];

  system.stateVersion = 5;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
