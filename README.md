# dotnix

Declarative system configuration used on my 2018 Intel Macbook Pro.

```bash
$ nix-info -m && date
 - system: `"x86_64-darwin"`
 - host os: `Darwin 23.4.0, macOS 10.16`
 - multi-user?: `no`
 - sandbox: `yes`
 - version: `nix-env (Nix) 2.19.2`
 - nixpkgs: `not found`

Mon Mar 18 09:12:30 PDT 2024
```

- [dotnix](#dotnix)
  - [What The Hell Is Going On Here!?](#what-the-hell-is-going-on-here)
    - [System Configuration with Nix](#system-configuration-with-nix)
    - [Understanding `dotnix`](#understanding-dotnix)
  - [Do](#do)
    - [Installation](#installation)
    - [Modifying the System Configuration](#modifying-the-system-configuration)
    - [Updating the System Configuration](#updating-the-system-configuration)
  - [Resources](#resources)

## What The Hell Is Going On Here!?

Check out my blog post [Fearless Tinkering with Nix](https://www.heneli.dev/blog/fearless-tinkering-nix) for an introduction to and conceptual overview of Nix covering:
  * what problems nix solves
  * the architecture of nix and the software engineering philosophies that shape it
  * ways that nix and its ecosystem can be used

### System Configuration with Nix

NixOS allows users to define their entire system configuration in a declarative manner via the Nix expression language. This includes specifying packages, services, users, and other system settings. The declarative nature of NixOS ensures that the system configuration is version-controllable, reproducible, and easy to share. It also simplifies system administration by providing a single source of truth for the entire system state.

Outside of NixOS, declarative system configuration can be achieved on MacOS through various Nix-based tools like `home-manager` and `nix-darwin`. These tools work with both standard and `flake`-based approaches:

| System Configuration | Platforms | Configuration File | Configuration Options | Notes |
|------|---------|-------|-------|-------|
| [NixOS](https://nixos.org/manual/nix/stable/) | NixOS | `configuration.nix` | Available in [Manual](https://nixos.org/manual/nixos/stable/options.html) or [NixOS Options Search](https://search.nixos.org/options) | |
| [Home-Manager](https://nix-community.github.io/home-manager/) | NixOS, Linux, MacOS | `home.nix` | [`accounts`, `home`, `launchd`, `nix`, `programs`, `services`, `systemd`, `targets.darwin`, `wayland`, `xdg`, `xsession`](https://mipmip.github.io/home-manager-option-search/) | Can also be configured as [NixOS module](https://nix-community.github.io/home-manager/index.html#sec-install-nixos-module) or [`nix-darwin` module](https://nix-community.github.io/home-manager/index.html#sec-install-nix-darwin-module) |
| [Nix-Darwin](https://daiderd.com/nix-darwin/) | MacOS | `darwin-configuration.nix` | [`enviroment`, `homebrew`, `launchd`, `networking`, `nix`, `programs`, `services`, `system`, `users`](https://daiderd.com/nix-darwin/manual/index.html#sec-options)  | Can manage [`homebrew`](https://brew.sh) package installations (ex. `brew install foo`) |

### Understanding `dotnix`

`dotnix` (this repo) is a flake-based system configuration for my machine powered by both Nix-Darwin and Home-Manager.

| File | Purpose | Notes |
|------|---------|-------|
| `darwin.nix` | My system configuration via [`nix-darwin`](https://github.com/LnL7/nix-darwin) including: <br />• packages from `nixpkgs`<br />• packages from homebrew<br />• MacOS settings (dock, scroll direction, etc)<br />...and more |• [Nix-Darwin Options](https://daiderd.com/nix-darwin/manual/index.html) - pre-defined configurations available with `nix-darwin`<br />• [NixPkgs](https://search.nixos.org/packages) - package repository + binary cache with 100k+ available packages |
| `home.nix` | My system configuration via [`home-manager`](https://github.com/nix-community/home-manager) including: <br />• apps (1Password, Firefox, VSCode)<br />• dev settings (`.git`, `.bashrc`)<br />• CLI tools (`bat`, `fzf`, `jq`)<br />...and more |• [Home-Manager Manual](https://nix-community.github.io/home-manager/index.html) - tool for declaratively managing system configuration, dotfiles, etc<br />• [Home-Manager Options](https://nix-community.github.io/home-manager/options.html) & [Options Search](https://mipmip.github.io/home-manager-option-search/) - pre-defined configurations available with `home-manager` |
| `flake.nix` | Takes Nix expressions as input, then output things like package definitions, development environments, or, as is the case here, system configurations.<br /><br />For this specific repository, we can think of it as wrapping `darwin.nix` and `home.nix` in order to provide it pinned dependencies and manage the outputs. | • [Zero to Nix Glossary](https://zero-to-nix.com/concepts/flakes)<br />• [xeiaso's Nix Flake Guides](https://xeiaso.net/blog/series/nix-flakes) |
| `flake.lock` | Pins dependencies used in flake inputs | |
| `bin/apply-system.sh` | Script to initialize and apply system configuration. Also downloads homebrew binary outside of nix, and configures default shell | Simple `nix run nix-darwin -- switch` invocation (same as running `darwin-rebuild switch`)|
| `bin/apply-system.sh` | Script to apply system configuration | Simple `nix run nix-darwin -- switch` invocation (same as running `darwin-rebuild switch`)|
| `bin/update-system.sh` | Script to update dependencies | Simple `nix flake update` invocation |

---

Software installed with `dotnix` is specified in following ways:
  - [Home-Manager Options](https://mipmip.github.io/home-manager-option-search/)
    - Via `programs.*` in `home.nix`
  - [Nixpkgs](https://search.nixos.org/packages) Package Set
    - Via `home.packages` in `home.nix`, corresponding to `nixpkgs` release at `flake.nix:inputs.nixpkgs.url`
  - [Flake Inputs](https://zero-to-nix.com/concepts/flakes#inputs)
    - Via `inputs` in `flake.nix` and pinned in `flake.lock`

System-wide `nix` settings are specified in `home.nix` under the following declarations:
  - `nix.package`
    - Determines which version of `nix` is used
      - Has matching declaration under `home.packages.config.nix.package`
  - `home.sessionVariables`
    - Environment variables set at login
  - `nix.settings`
    - Replaces configuration that's usually found at `/etc/nix/nix.conf`
    - Sets feature flags, binary cache keys and locations, etc
  - `nix.registry`
    - Replaces configuration that's usually found at `/etc/nix/registry.json`
    - Same as default found at https://github.com/NixOS/flake-registry
      - > "The flake registry serves as a convenient method for the Nix CLI to associate short names with flake URIs, such as linking `nixpkgs` to `github:NixOS/nixpkgs/nixpkgs-unstable.`"

## Do

### Installation

1. Install `nix`

Follow the [Zero-to-Nix Quickstart Guide](https://zero-to-nix.com/start/install) for a flake-based `nix` installation.

2. Setup `dotnix` repo

```bash
$ mkdir -p ~/.config
$ cd ~/.config
$ git clone https://github.com/hkscarf/dotnix
```

FIXME TODO - Need to describe configuring. Replacing hostname, user, home dir, etc

3. Apply system configurations

```bash
$ cd ~/.config/dotnix/
$ ./bin/init-system.sh
```

### Modifying the System Configuration

1. Modify configuration files

For example, add a new package to install in `darwin.nix` or move to a newer release of `nixpkgs` in `flake.nix`.

2. Apply system configurations

```bash
$ cd ~/.config/dotnix/
$ ./bin/apply-system.sh
```


### Updating the System Configuration

1. Update dependencies in `flake.lock`

```bash
$ cd ~/.config/dotnix/
$ ./bin/update-system.sh
```

2. Apply system configurations

```bash
$ cd ~/.config/dotnix/
$ ./bin/apply-system.sh
```

## Resources

Declarative macOS Configuration - Using `nix-darwin` and `home-manager`: https://xyno.space/post/nix-darwin-introduction

Setting up Nix on macOS: https://davi.sh/til/nix/nix-macos-setup/

Switching to nix-darwin and Flakes: https://evantravers.com/articles/2024/02/06/switching-to-nix-darwin-and-flakes/
