# PROVVISORIO: serve solo a far valutare il flake prima dell'installazione.
# All'installazione va sostituito con l'output di
#   nixos-generate-config --no-filesystems --show-hardware-config
# (--no-filesystems: dischi e cifratura li descrive disk.nix).
{ lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "usb_storage"
    "sd_mod"
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
