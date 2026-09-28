# NixOS Configuration

Flake for two hosts: `laptop` and `desktop`. Everything shared lives in `common/`,
everything machine-specific in `hosts/<hostname>/`.

## Quick Start

```bash
sudo nixos-rebuild switch --flake .#laptop
sudo nixos-rebuild switch --flake .#desktop
```

## Structure

```
.
├── flake.nix                 # inputs + mkHost + the two hosts
├── common/                   # shared by every host
│   ├── default.nix           # user, greetd, fonts, /etc bits, home-manager wiring
│   ├── system.nix            # boot, nix, locale, security
│   ├── desktop.nix           # hyprland, pipewire, bluetooth, udisks/gvfs/flatpak
│   └── packages.nix          # all system packages
├── hosts/
│   ├── laptop/               # NetworkManager, Tailscale, TLP, KDE Connect
│   └── desktop/              # bridge+VLANs, AMD/ROCm, Ollama, Sunshine, libvirtd
└── home/                     # home-manager + stylix theming
```

## Where things go

| Task | File |
|------|------|
| Add/remove a host | `flake.nix` |
| Anything both machines need | `common/` |
| Anything one machine needs | `hosts/<hostname>/default.nix` |
| System packages | `common/packages.nix` |
| Theme/colors | `home/stylix.nix` |

## Conventions

`mkHost` passes `inputs`, `unstable`, `hostname` and `username` to every module:

```nix
{ unstable, inputs, username, ... }:
{
  environment.systemPackages = [
    unstable.some-package
    inputs.some-flake.packages.${pkgs.stdenv.hostPlatform.system}.thing
  ];
}
```

So `common/` never hardcodes a username — the user, its home and greetd's session
are all derived from the `username` passed in `flake.nix`.

## Adding a host

1. `hosts/<hostname>/{default.nix,hardware-configuration.nix}`
2. In `flake.nix`:

```nix
newhost = mkHost {
  hostname = "newhost";
  username = "user";
  # extraModules = [ inputs.foo.nixosModules.default ];
};
```

3. `sudo nixos-rebuild switch --flake .#newhost`
