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

A `justfile` at the repo root wraps the common commands. Run `just` (or `just --list`) to see all recipes.

| Recipe | What it does |
|--------|-------------|
| `just switch` | Rebuild and activate the current host |
| `just check` | Evaluate every host config, build nothing |
| `just fmt` | Format all Nix files |
| `just update` | Update all flake inputs |

The underlying commands, if you prefer to run them directly:

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

### Secrets

Secrets are encrypted with agenix. Recipient policy lives in the root-level
`secrets.nix`; encrypted `.age` files are safe to commit. To finish the
one-time Grimmory migration without changing its existing database password:

```
sudo cp /var/lib/grimmory/secrets.env /tmp/grimmory.env
sudo chown "$USER" /tmp/grimmory.env
chmod 600 /tmp/grimmory.env
cd ~/.config/nix
agenix -e secrets/grimmory.env.age < /tmp/grimmory.env
rm /tmp/grimmory.env
git add secrets/grimmory.env.age
nix flake check --no-build
sudo nixos-rebuild switch --flake .
```

The host configuration deliberately keeps using the old root-owned file until
`secrets/grimmory.env.age` exists. After the switch confirms both services are
healthy, `/var/lib/grimmory/secrets.env` is obsolete and can be removed.

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
