{ pkgs, unstable, ... }:

{
  virtualisation.libvirtd = {
    enable = true;
    package = unstable.libvirt;
    # Use modular daemon mode (default in NixOS 25.11+)
    # This replaces the legacy monolithic libvirtd daemon
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

  # Kept virt-viewer, removed OVMFFull and swtpm as they are handled by the module
  environment.systemPackages = with pkgs; [ virt-viewer ];
}
