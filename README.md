# NixOS Configuration

Modular NixOS flake configuration for laptop and desktop systems.

## Quick Start

```bash
# Rebuild laptop
sudo nixos-rebuild switch --flake .#laptop

# Rebuild desktop
sudo nixos-rebuild switch --flake .#desktop
```

## Structure

```
.
├── flake.nix                 # Main entry point
├── lib/
│   └── mkHost.nix            # Host builder helper
├── hosts/
│   ├── laptop/
│   │   ├── default.nix       # Laptop config (user: stefanom)
│   │   └── hardware-configuration.nix
│   └── desktop/
│       ├── default.nix       # Desktop config (user: sm)
│       ├── hardware-configuration.nix
│       └── network.nix       # Bridge + VLAN networking
├── modules/
│   ├── core/                 # Core system modules
│   │   ├── boot.nix          # Kernel, bootloader
│   │   ├── nix.nix           # Flakes, garbage collection
│   │   ├── locale.nix        # Timezone, locales
│   │   └── security.nix      # Polkit, rtkit, keyring
│   ├── desktop/              # Desktop environment
│   │   ├── hyprland.nix      # Wayland compositor
│   │   ├── audio.nix         # PipeWire
│   │   ├── bluetooth.nix
│   │   └── services.nix      # Udisks, gvfs, flatpak
│   ├── packages.nix          # System-wide packages
│   └── virtualization.nix    # Libvirtd, QEMU
└── home/
    ├── default.nix           # Home-manager base
    └── stylix.nix            # Theming and colors
```

## Configuration Entry Points

| Task | File |
|------|------|
| Add/remove hosts | `flake.nix` |
| Host-specific settings | `hosts/<hostname>/default.nix` |
| System packages | `modules/packages.nix` |
| Kernel/boot options | `modules/core/boot.nix` |
| Nix settings | `modules/core/nix.nix` |
| Locale/timezone | `modules/core/locale.nix` |
| Security services | `modules/core/security.nix` |
| Hyprland | `modules/graphical/hyprland.nix` |
| Audio | `modules/graphical/audio.nix` |
| Bluetooth | `modules/graphical/bluetooth.nix` |
| Desktop services | `modules/graphical/services.nix` |
| Virtualization | `modules/virtualization.nix` |
| Theme/colors | `home/stylix.nix` |

## How It Works

The `lib/mkHost.nix` helper automatically includes:
- All core modules (`modules/core/*`)
- All desktop modules (`modules/graphical/*`)
- System packages (`modules/packages.nix`)
- Virtualization (`modules/virtualization.nix`)
- Home-manager with stylix integration

Each host only needs to define its specific configuration in `hosts/<hostname>/default.nix`.

### Accessing Unstable Packages

Unstable packages are available via `unstable` in both NixOS modules and home-manager:

```nix
# In any module
{ unstable, ... }:
{
  environment.systemPackages = [
    unstable.some-package
  ];
}
```

## Hosts

### Laptop

- **User:** stefanom
- **Display:** greetd + Hyprland
- **Network:** NetworkManager
- **Services:** Tailscale, TLP, KDE Connect

### Desktop

- **User:** sm
- **Network:** Bridge with VLANs (10, 20, 40)
- **GPU:** AMD with ROCm
- **Services:** Ollama, Looking Glass, QMK
- **Extra:** Determinate Nix

## Adding a New Host

1. Create `hosts/<hostname>/default.nix` and `hardware-configuration.nix`
2. Add to `flake.nix`:

```nix
newhost = mkHost {
  hostname = "newhost";
  username = "user";
  modules = [ ./hosts/newhost ];
};
```

3. Rebuild: `sudo nixos-rebuild switch --flake .#newhost`
