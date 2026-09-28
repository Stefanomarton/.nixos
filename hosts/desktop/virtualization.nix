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

  # Looking Glass shared memory for GPU passthrough
  systemd.tmpfiles.rules = [ "f /dev/shm/looking-glass 0660 ${username} qemu-libvirtd -" ];

  environment.systemPackages = with pkgs; [
    virt-viewer
    looking-glass-client
  ];
}
