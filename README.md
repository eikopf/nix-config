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
    - `modules/nixos` defines NixOS-specific configurations.
    - `modules/languages` is responsible for controlling per-language configurations.
- `wallpaper` holds wallpaper assets used by the desktop configurations.

```
.
├── flake.lock
├── flake.nix
├── home
├── hosts
│   ├── pilatus
│   ├── rigi
│   └── wildspitz
├── modules
│   ├── common
│   │   ├── default.nix
│   │   └── *.nix
│   ├── darwin
│   │   ├── default.nix
│   │   └── *.nix
│   ├── languages
│   │   └── default.nix
│   └── nixos
│       ├── default.nix
│       └── *.nix
└── wallpaper
```

## Usage

### Rebuilding

On NixOS hosts:
```
sudo nixos-rebuild switch --flake ~/.config/nix
```

On macOS hosts:
```
darwin-rebuild switch --flake ~/.config/nix
```

Check all host configurations evaluate correctly (no build):
```
nix flake check --no-build
```

Format all Nix files:
```
nix fmt
```

## Notes

### Darwin Hosts

The steps for setting up a new macOS host are as follows:
1. Duplicate an existing Darwin host configuration and modify it to use the new filename.
2. Install the Lix fork of Nix.[^lix]
3. Clone this repository into `~/.config/nix`.
4. Bootstrap `nix-darwin` using the same branch pinned in `flake.nix`'s `darwin` input (currently `nix-darwin-26.05`):
   ```
   nix run github:LnL7/nix-darwin/<branch>#darwin-rebuild -- switch --flake ~/.config/nix
   ```
   Replace `<branch>` with the ref from the `darwin.url` line in `flake.nix`.
5. At this point `nix-darwin` is installed and future rebuilds can be run with `darwin-rebuild switch --flake ~/.config/nix` instead.


[^lix]: The darwin hosts assume they are installed with Lix; this specificity is necessary to get some tools (like `nixd`) to work correctly.
