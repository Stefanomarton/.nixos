# Claude Code Context

This is a NixOS flake configuration for two hosts: laptop and desktop.

## Architecture

- **`flake.nix`** - Main entry point, defines hosts using `mkHost` helper
- **`lib/mkHost.nix`** - Host builder that auto-imports all shared modules and integrates home-manager with stylix
- **`hosts/<hostname>/`** - Host-specific configs (hardware, users, services)
- **`modules/core/`** - Core system: boot, nix settings, locale, security
- **`modules/desktop/`** - Desktop env: hyprland, audio, bluetooth, services
- **`modules/packages.nix`** - System-wide packages (edit here to add packages)
- **`modules/virtualization.nix`** - Libvirtd, QEMU, virt-manager
- **`home/`** - Home-manager config with stylix theming

## Hosts

| Host | User | Key Features |
|------|------|--------------|
| laptop | stefanom | NetworkManager, greetd, Tailscale, TLP |
| desktop | sm | Bridge+VLANs, AMD GPU/ROCm, Ollama, Looking Glass, Determinate Nix |

## Key Patterns

### Accessing unstable packages
```nix
{ unstable, ... }:
{
  environment.systemPackages = [ unstable.package-name ];
}
```

### Adding a new host
1. Create `hosts/<name>/default.nix` and `hardware-configuration.nix`
2. Add entry in `flake.nix` using `mkHost { hostname; username; modules; }`

### Module organization
- Core modules use `modules/core/default.nix` as entry point
- Desktop modules use `modules/desktop/default.nix` as entry point
- Both entry points import all submodules in their directory

## Rebuild Commands

```bash
sudo nixos-rebuild switch --flake .#laptop
sudo nixos-rebuild switch --flake .#desktop
```

## File Purposes

| File | Purpose |
|------|---------|
| `modules/core/boot.nix` | Zen kernel, systemd-boot, EFI |
| `modules/core/nix.nix` | Flakes, GC (weekly), cachix |
| `modules/core/locale.nix` | Europe/Rome, en_US/it_IT |
| `modules/core/security.nix` | Polkit, rtkit, dbus, GNOME keyring |
| `modules/desktop/hyprland.nix` | Wayland compositor + XWayland |
| `modules/desktop/audio.nix` | PipeWire with ALSA/PulseAudio compat |
| `modules/desktop/bluetooth.nix` | Bluetooth + Blueman |
| `modules/desktop/services.nix` | Udisks2, gvfs, flatpak |
| `modules/packages.nix` | All system packages (~100+) |
| `modules/virtualization.nix` | VMs, libvirtd, QEMU, TPM |
| `home/stylix.nix` | Theme: black-metal-nile, gammastep, dunst |

## Conventions

- Unfree packages allowed (`config.allowUnfree = true`)
- Home-manager uses global pkgs and user packages
- Backup extension for home-manager conflicts: `.backup`
- Unstable channel available via `specialArgs` as `unstable`
