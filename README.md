# NixOS di Stefano

Un solo flake per tre computer. Ogni computer è un file, `hosts/<nome>/default.nix`, che elenca le
**feature** che usa. Ogni feature è un file in `modules/` e contiene tutto quello che le serve:
pacchetti, servizi e configurazione utente (home-manager).

| Host | Cos'è | Utente |
|------|-------|--------|
| `desktop` | PC fisso di casa (AMD): homelab, VM con passthrough GPU, LLM locali | `sm` |
| `laptop` | portatile personale (Intel) | `sm` |
| `tm-laptop` | portatile di lavoro TEAM mastery: disco cifrato, Secure Boot, VPN aziendale | `sm` |

```bash
sudo nixos-rebuild switch --flake ~/.nixos#<host>
```

## Struttura

```
flake.nix            input e i tre host
modules/             una feature per file
hosts/<host>/        cosa usa l'host + hardware e servizi solo suoi
assets/              esclusioni Nextcloud
```

## Feature

| Feature | Contenuto | desktop | laptop | tm-laptop |
|---------|-----------|:-:|:-:|:-:|
| `base` | avvio, nix, lingua, utente `sm`, home-manager | ✓ | ✓ | ✓ |
| `hyprland` | Hyprland con login automatico, audio, bluetooth, strumenti Wayland | ✓ | ✓ | ✓ |
| `theme` | font, tema stylix, notifiche dunst | ✓ | ✓ | ✓ |
| `keyboard` | kmonad, solaar | ✓ | ✓ | ✓ |
| `tools` | shell e strumenti da riga di comando | ✓ | ✓ | ✓ |
| `editors` | Emacs, Neovim, VS Code, correttori ortografici | ✓ | ✓ | ✓ |
| `dev` | git, linguaggi, LSP, Claude Code | ✓ | ✓ | ✓ |
| `documents` | LaTeX, Typst, Pandoc, PDF, LibreOffice, Zotero, note | ✓ | ✓ | ✓ |
| `web` | Chromium, Thunderbird, Teams, Bitwarden | ✓ | ✓ | ✓ |
| `portable` | NetworkManager, TLP, luminosità | | ✓ | ✓ |
| `virtualization` | VM con libvirt/QEMU e virt-manager, TPM emulato e UEFI Secure Boot (Windows 11) | ✓ | | ✓ |
| `homelab` | Netbird, Nextcloud, Home Assistant, Moonlight, opencode su LLM locali | ✓ | ✓ | |
| `phone` | KDE Connect, scrcpy, adb | ✓ | ✓ | |
| `remote` | AnyDesk, Remmina, FreeRDP | ✓ | ✓ | |
| `maker` | CAD, stampa 3D, QMK, microcontrollori | ✓ | ✓ | |
| `media` | musica, video, foto, OBS, messaggi, giochi | ✓ | ✓ | |

Le feature senza spunta nella colonna tm-laptop sono personali e sul portatile di lavoro non sono installate.

## tm-laptop: sicurezza

Tutto è in [`hosts/tm-laptop/`](hosts/tm-laptop/): `default.nix` per la configurazione, `disk.nix` per il disco.

| Requisito | Come |
|-----------|------|
| Cifratura del disco | LUKS2 su tutto il sistema (`cryptroot`, ext4); fuori resta solo la partizione EFI. Layout dichiarato con [disko](https://github.com/nix-community/disko) |
| Sblocco | TPM2 legato al PCR 7 (stato del Secure Boot): la chiave esce dal TPM solo se si avvia questo NixOS firmato. Restano la passphrase e una recovery key |
| Avvio verificato | Secure Boot con chiavi proprie tramite [lanzaboote](https://github.com/nix-community/lanzaboote): kernel e initrd firmati, i sistemi non firmati (chiavette, altri OS) non partono |
| VPN | OpenVPN (`openvpn-tm.service`), si accende a mano. Il profilo `.ovpn` sta in `/etc/openvpn/tm.ovpn` (root, 600) e non è nel repository |
| Rete | firewall NixOS attivo, nessuna porta in ingresso aperta |
| Software | solo le feature di lavoro (tabella sopra); niente accesso remoto, niente servizi dell'homelab |
| VM Windows | libvirt/QEMU; i dischi delle VM (`/var/lib/libvirt/images`) stanno dentro il volume cifrato. Rete NAT: la VM esce attraverso il portatile, VPN compresa, e da fuori non è raggiungibile |

Il repository è pubblico: non contiene segreti, profili VPN, chiavi o nomi interni di TEAM mastery.

### Installazione

Servono una chiavetta con la ISO minimal di NixOS 26.05 e il profilo `.ovpn` di TEAM mastery. Nel BIOS
il Secure Boot va **disattivato** per tutta l'installazione.

**1. Disco, sistema, chiavi Secure Boot** (dalla chiavetta, in rete via cavo o `nmtui`):

```bash
sudo -i
export NIX_CONFIG="experimental-features = nix-command flakes"
nix-shell -p git sbctl
git clone https://github.com/Stefanomarton/.nixos /tmp/nixos && cd /tmp/nixos
lsblk   # se il disco non è /dev/nvme0n1, correggere hosts/tm-laptop/disk.nix

# Cancella il disco, crea EFI + LUKS2 e monta in /mnt. Chiede la passphrase LUKS: lunga, da conservare.
nix run github:nix-community/disko/v1.13.0 -- --mode destroy,format,mount --flake .#tm-laptop

# Hardware reale al posto del file provvisorio (dischi e cifratura stanno in disk.nix)
nixos-generate-config --no-filesystems --show-hardware-config > hosts/tm-laptop/hardware-configuration.nix

# Chiavi Secure Boot, copiate nel sistema installato (lanzaboote firma con queste)
sbctl create-keys && mkdir -p /mnt/var/lib && cp -a /var/lib/sbctl /mnt/var/lib/

git add -A   # il flake vede solo i file tracciati da git
nixos-install --flake .#tm-laptop --no-root-passwd
nixos-enter --root /mnt -c 'passwd sm'   # password per sudo
cp -a /tmp/nixos /mnt/home/sm/.nixos && chown -R 1000:100 /mnt/home/sm/.nixos
reboot
```

Al primo avvio la passphrase LUKS va digitata: il TPM non è ancora registrato.

**2. Secure Boot.** Controllare che tutto sia firmato. I file `kernel-*` non firmati sono normali:

```bash
sudo sbctl verify
```

Poi nel BIOS: Secure Boot **attivo** e *Reset to Setup Mode*. Non usare "Clear all Secure Boot keys",
perché cancella anche la lista di revoca (dbx). Al riavvio, registrare le chiavi; `--microsoft` tiene i
certificati Microsoft che servono al firmware di alcune periferiche:

```bash
sudo sbctl enroll-keys --microsoft
```

Riavviare e controllare che `bootctl status` mostri `Secure Boot: enabled (user)`.

**3. Sblocco con TPM2 e recovery key:**

```bash
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/disk/by-partlabel/disk-main-luks
sudo systemd-cryptenroll --recovery-key /dev/disk/by-partlabel/disk-main-luks
```

La recovery key va consegnata a TEAM mastery: è l'equivalente della chiave di ripristino BitLocker. Dal
riavvio successivo il disco si sblocca da solo.

**4. VPN:**

```bash
sudo install -D -m 600 -o root -g root tm.ovpn /etc/openvpn/tm.ovpn
sudo systemctl start openvpn-tm      # stop per spegnerla
journalctl -u openvpn-tm -f          # log
```

Se la VPN chiede utente e password: scriverli su due righe in `/etc/openvpn/tm.auth` (root, 600) e
aggiungere al profilo la riga `auth-user-pass /etc/openvpn/tm.auth`.

**5.** Committare il nuovo `hosts/tm-laptop/hardware-configuration.nix`.

### VM Windows

Una volta sola: avviare la rete NAT di libvirt e scaricare i driver VirtIO per Windows.

```bash
sudo virsh net-autostart default && sudo virsh net-start default
curl -LO https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso
```

In virt-manager: *Nuova VM* → ISO di Windows → prima di installare spuntare *Personalizza configurazione*:

- **Panoramica → Firmware**: UEFI con Secure Boot (`OVMF_CODE.secboot`);
- **Aggiungi hardware → TPM**: emulato, versione 2.0 (Windows 11 lo richiede);
- **Disco e rete**: bus `VirtIO`, più un secondo lettore CD con `virtio-win.iso`. Durante
  l'installazione, *Carica driver* → `viostor\w11\amd64`, per far vedere il disco a Windows;
- **Dopo l'installazione**: dentro Windows, `virtio-win-guest-tools.exe` dallo stesso CD (driver di rete,
  video e appunti condivisi).

### Verifiche

```bash
bootctl status                                                      # Secure Boot: enabled (user)
sudo sbctl status
sudo systemd-cryptenroll /dev/disk/by-partlabel/disk-main-luks      # slot: password, recovery, tpm2
sudo cryptsetup luksDump /dev/disk/by-partlabel/disk-main-luks      # LUKS2, token systemd-tpm2
sudo iptables -S nixos-fw                                           # nessuna porta accettata
systemctl status openvpn-tm
```

### Se il disco chiede di nuovo la passphrase

Succede quando cambia lo stato del Secure Boot, per esempio dopo un aggiornamento della lista di
revoca (dbx) del firmware o un reset delle chiavi. Il TPM allora non rilascia più la chiave: si
sblocca con la passphrase e si registra di nuovo il TPM:

```bash
sudo systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=7 /dev/disk/by-partlabel/disk-main-luks
```

## Uso quotidiano

```bash
sudo nixos-rebuild switch --flake ~/.nixos#<host>   # applica la configurazione
nix flake update && sudo nixos-rebuild switch --flake ~/.nixos#<host>   # aggiorna tutto
```

| Voglio… | Dove |
|---------|------|
| un programma su tutti gli host | la feature giusta in `modules/` |
| un programma su un host solo | `environment.systemPackages` in `hosts/<host>/default.nix` |
| una feature nuova | nuovo file `modules/<nome>.nix`, poi aggiungerlo agli `imports` degli host che la vogliono |
| un host nuovo | `hosts/<nome>/default.nix` + `hardware-configuration.nix`, poi il nome nella lista in `flake.nix` |

