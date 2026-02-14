{ pkgs, unstable, ... }:

{
  virtualisation.libvirtd = {
    package = unstable.libvirt;
    enable = true;
    qemu = {
      package = unstable.qemu;
      runAsRoot = true;
      swtpm.enable = true;
      vhostUserPackages = [ pkgs.virtiofsd ];
    };
  };

  virtualisation.spiceUSBRedirection.enable = true;

  programs.virt-manager = {
    enable = true;
    package = unstable.virt-manager;
  };

  environment.systemPackages = with pkgs; [ OVMFFull swtpm virt-viewer ];
}
