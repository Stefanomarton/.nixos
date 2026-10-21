# NixOS flake: desktop, laptop, tm-laptop

Panoramica e installazione del tm-laptop in README.md: tienilo allineato.

## Struttura

- `flake.nix`: input e `mkHost hostname`, che passa `inputs`, `unstable`, `hostname` e `username = "sm"` come specialArgs e importa solo `hosts/<hostname>`.
- `hosts/<host>/default.nix`: elenca negli `imports` le feature da `modules/`, più hardware e servizi solo suoi.
- `modules/<feature>.nix`: una feature per file (pacchetti, servizi e la sua parte home-manager in `home-manager.users.${username}`). Prima riga: commento su cosa contiene.
- `assets/`: file referenziati dai moduli (esclusioni Nextcloud).

Feature personali (`homelab`, `phone`, `remote`, `maker`, `media`): mai su `tm-laptop`.

## Regole

- Repo **pubblico**: niente segreti, profili VPN, chiavi o nomi interni di TEAM mastery. I segreti stanno fuori dal repo (es. `/etc/openvpn/tm.ovpn`) e i moduli li leggono da un percorso.
- tm-laptop: login automatico e niente blocco schermo sono una scelta di Stefano, non correggerli.
- `hosts/tm-laptop/hardware-configuration.nix` è provvisorio finché la macchina non viene installata; i dischi li descrive `disk.nix` (disko).
- Pacchetti unstable: `unstable.pkg`. Input del flake: `inputs.x.packages.${pkgs.stdenv.hostPlatform.system}` (mai `pkgs.system`).
- Unfree permesso (in `flake.nix`); niente pacchetti segnalati insicuri.
- Input del flake con `inputs.nixpkgs.follows` (nixpkgs o nixpkgs-unstable), tranne hyprland: tiene il suo nixpkgs per usare la cache hyprland.cachix.org.
- Commenti in italiano, brevi, solo dove il perché non è ovvio.

## Verifica

Senza buildare (deve uscire senza warning, per ogni host):

```bash
nix eval --raw .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath
```

Spostando pacchetti tra feature, confronta la lista prima e dopo:

```bash
nix eval --json .#nixosConfigurations.<host>.config.environment.systemPackages --apply 'map (p: p.name)' | jq -r '.[]' | sort
```
