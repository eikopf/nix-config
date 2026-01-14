# `nix-config`

My personal Nix configuration.

## Structure
This flake is roughly structured as follows:
- `flake.nix` is the entrypoint for configurations on a per-host basis.
- `home` defines the `home-manager` configuration.
- `hosts` contains the bulk of the per-host configurations.
- `modules` holds all other configuration modules, including:
    - `modules/common` defines configurations for both NixOS and macOS.
    - `modules/darwin` defines macOS-specific configurations.
    - `modules/languages` is responsible for controlling per-language configurations.

```
.
├── flake.lock
├── flake.nix
├── home
├── hosts
│   ├── pilatus
│   └── rigi
└── modules
    ├── common
    │   ├── default.nix
    │   └── *.nix
    ├── darwin
    │   ├── default.nix
    │   └── *.nix
    └── languages
        ├── default.nix
        └── selection.nix
```

## Notes

### Darwin Hosts

The steps for setting up a new macOS host are as follows:
1. Duplicate an existing Darwin host configuration and modify it to use the new filename.
2. Install the Lix fork of Nix.[^lix]
3. Clone this repository into `~/.config/nix`.
4. Run `nix run nix-darwin/nix-darwin-24.11#darwin-rebuild -- switch ~/.config/nix` to build the configuration on the current host. Notice that this explicitly points to the `24.11` version of `nix-darwin`, but this should match with the version of `nix-darwin` defined in `flake.nix`.
5. At this point `nix-darwin` is installed and future rebuilds can be run with `darwin-rebuild switch --flake ~/.config/nix` instead.


[^lix]: The darwin hosts assume they are installed with Lix; this specificity is necessary to get some tools (like `nixd`) to work correctly.
