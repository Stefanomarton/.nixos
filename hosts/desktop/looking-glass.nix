# Looking Glass per la VM con passthrough della GPU (vfio in hardware-configuration.nix).
{ pkgs, username, ... }:

{
  # Looking Glass shared memory for GPU passthrough
  systemd.tmpfiles.rules = [ "f /dev/shm/looking-glass 0660 ${username} qemu-libvirtd -" ];

  environment.systemPackages = [ pkgs.looking-glass-client ];
}
