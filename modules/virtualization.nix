{ pkgs, unstable, ... }:

{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = unstable.qemu;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };

  virtualisation.spiceUSBRedirection.enable = true;

  programs.virt-manager.enable = true;

  environment.systemPackages = with pkgs; [
    OVMFFull
    swtpm
    virt-viewer
  ];
}
