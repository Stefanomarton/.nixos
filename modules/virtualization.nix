# Macchine virtuali: libvirt/QEMU con virt-manager, TPM emulato e UEFI Secure Boot (per Windows 11).
{
  pkgs,
  unstable,
  username,
  ...
}:

{
  # Modular daemon mode (default in NixOS 25.11+) replaces the legacy
  # monolithic libvirtd daemon.
  virtualisation.libvirtd = {
    enable = true;
    package = unstable.libvirt;
    qemu = {
      package = unstable.qemu;
      runAsRoot = false;
      swtpm.enable = true;
      vhostUserPackages = [ pkgs.virtiofsd ];
    };
  };

  # Disable legacy libvirtd socket to prevent conflicts with modular daemons
  systemd.sockets.libvirtd.enable = false;

  virtualisation.spiceUSBRedirection.enable = true;

  programs.virt-manager = {
    enable = true;
    package = unstable.virt-manager;
  };

  users.users.${username}.extraGroups = [ "libvirtd" ];

  environment.systemPackages = with pkgs; [
    virt-viewer
    virglrenderer
  ];
}
