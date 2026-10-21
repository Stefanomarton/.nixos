# Desktop remoto: AnyDesk, Remmina, FreeRDP.
{ pkgs, unstable, ... }:

{
  environment.systemPackages = with pkgs; [
    unstable.anydesk
    remmina
    freerdp
  ];
}
