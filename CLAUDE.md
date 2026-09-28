# Claude Code Context

NixOS flake for two hosts: laptop and desktop.

## Architecture

- **`flake.nix`** — inputs, the `mkHost` helper (inline), and the two hosts
- **`common/`** — everything both machines share; auto-imported by `mkHost`
- **`hosts/<hostname>/`** — host-specific only (hardware, network, services)
- **`home/`** — home-manager config with stylix theming

`mkHost` builds `nixpkgs.lib.nixosSystem` with `modules = [ ./common ./hosts/${hostname} ] ++ extraModules`
and passes `inputs`, `unstable`, `hostname`, `username` through `specialArgs`.

## Hosts

| Host | User | stateVersion | Key features |
|------|------|--------------|--------------|
| laptop | stefanom | 24.05 | NetworkManager, Tailscale, TLP, KDE Connect |
| desktop | sm | 25.11 | bridge+VLANs, AMD GPU/ROCm, Ollama, Sunshine, libvirtd + Looking Glass, openlogi, kmonad module |

## File purposes

| File | Purpose |
|------|---------|
| `common/default.nix` | user (`users.users.${username}`), greetd→Hyprland, udev uinput, `/etc/zshenv`, xdg user-dirs, base fonts, home-manager wiring |
| `common/system.nix` | zen kernel, systemd-boot, nix settings + GC, Europe/Rome + it_IT locales, polkit/rtkit/keyring |
| `common/desktop.nix` | Hyprland (flake package), PipeWire, Bluetooth, udisks2/gvfs/flatpak |
| `common/packages.nix` | all system packages (~250), plus netbird/emacs/obs/direnv programs |
| `hosts/desktop/network.nix` | br0 bridge + vlan10/20/40, static IPs, default route on br0 |
| `hosts/desktop/virtualization.nix` | libvirtd/QEMU/swtpm, virt-manager, `libvirtd` group, Looking Glass shm |
| `home/stylix.nix` | theme black-metal-nile, dunst |

## Key patterns

```nix
# unstable packages
{ unstable, ... }: { environment.systemPackages = [ unstable.pkg ]; }

# flake inputs (never destructured as top-level args)
{ pkgs, inputs, ... }:
let system = pkgs.stdenv.hostPlatform.system;
in { environment.systemPackages = [ inputs.neovim.packages.${system}.default ]; }
```

- Never hardcode a username in `common/` — use the `username` arg.
- Use `pkgs.stdenv.hostPlatform.system`, not the deprecated `pkgs.system`.
- Adding a flake input = one edit (the `inputs` block); `outputs` takes `@inputs`.
- Unfree allowed; `permittedInsecurePackages` is set once in `flake.nix`.

## Rebuild

```bash
sudo nixos-rebuild switch --flake .#laptop
sudo nixos-rebuild switch --flake .#desktop
```

Cheap check without building: `nix eval .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath`
(must be warning-free).
