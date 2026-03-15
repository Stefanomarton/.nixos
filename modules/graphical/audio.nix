{ ... }:

{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.extraConfig."51-disable-unwanted-audio" = {
      "monitor.alsa.rules" = [{
        matches = [
          # Replace these strings with the exact node.names from the command above
          {
            "node.name" = "~alsa_output.pci-0000_xx_xx.*hdmi.*";
          } # Hides Sink 55
          {
            "node.name" = "~alsa_output.usb-.*";
          } # Hides Sink 59 (but keeps the USB mic input!)
          {
            "node.name" = "~alsa_output.pci-0000_xx_xx.*iec958.*";
          } # Hides Sink 62
          {
            "node.name" = "~alsa_input.pci-0000_xx_xx.*analog.*";
          } # Hides Source 63
        ];
        actions = { update-props = { "node.disabled" = true; }; };
      }];
    };
  };
}
