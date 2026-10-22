# tm-laptop: portatile di lavoro TEAM mastery.
# Disco cifrato (LUKS2) sbloccato dal TPM2 solo con Secure Boot attivo, VPN OpenVPN aziendale.
# Niente feature personali (homelab, telefono, desktop remoto, maker, media).
# Installazione e verifiche: README.md, sezione "tm-laptop".
{
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./disk.nix
    inputs.disko.nixosModules.disko
    inputs.lanzaboote.nixosModules.lanzaboote

    ../../modules/base.nix
    ../../modules/hyprland.nix
    ../../modules/theme.nix
    ../../modules/keyboard.nix
    ../../modules/tools.nix
    ../../modules/editors.nix
    ../../modules/dev.nix
    ../../modules/documents.nix
    ../../modules/web.nix
    ../../modules/portable.nix
    ../../modules/virtualization.nix # VM Windows
  ];

  # Secure Boot: lanzaboote firma kernel e initrd con le chiavi in /var/lib/sbctl
  # e prende il posto di systemd-boot.
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  # LUKS sbloccato dal TPM2 (registrato con systemd-cryptenroll, legato al PCR 7 = stato Secure Boot).
  # Passphrase e recovery key restano come chiavi di riserva.
  boot.initrd.systemd = {
    enable = true;
    tpm2.enable = true;
  };
  boot.initrd.luks.devices.cryptroot.crypttabExtraOpts = [ "tpm2-device=auto" ];

  # VPN aziendale: il profilo sta fuori dal repo (root, 600) e non entra mai in git.
  # Accensione: sudo systemctl start openvpn-tm
  services.openvpn.servers.tm = {
    config = "config /etc/openvpn/tm.ovpn";
    autoStart = false;
    updateResolvConf = true; # DNS dati dalla VPN
  };

  # 16 GB saldati e nessuna partizione di swap: con la VM Windows accesa serve margine
  zramSwap.enable = true;

  # Lettore di impronte Synaptics 06cb:0106 (driver synaptics di libfprint).
  # Registrazione: fprintd-enroll; poi vale per sudo e polkit (login e blocco schermo non ci sono).
  services.fprintd.enable = true;

  environment.systemPackages = with pkgs; [
    sbctl # chiavi e verifica Secure Boot
    tpm2-tools
  ];

  system.stateVersion = "26.05";
}
