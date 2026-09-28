{ pkgs, unstable, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./network.nix
    ./virtualization.nix
  ];

  # AMD GPU
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.amdgpu.opencl.enable = true;

  # Hide the audio sinks this box never uses. Get the real node.name values
  # with `wpctl status` before adding more matches.
  services.pipewire.wireplumber.extraConfig."51-disable-unwanted-audio" = {
    "monitor.alsa.rules" = [
      {
        matches = [ { "node.name" = "~alsa_output.usb-.*"; } ]; # keeps the USB mic input
        actions.update-props."node.disabled" = true;
      }
    ];
  };

  services.ollama = {
    package = unstable.ollama-rocm;
    enable = true;
  };

  services.open-webui.enable = true;

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true; # needed for KMS/WLR screen capture
    openFirewall = true;
  };

  services.hyprwhspr-rs = {
    enable = true;
    package = pkgs.hyprwhspr-rs.override {
      whisper-cpp = pkgs.whisper-cpp.override { rocmSupport = true; };
      onnxruntime = pkgs.onnxruntime.override { rocmSupport = true; };
    };
  };

  programs.openlogi.enable = true;

  environment.systemPackages = [ pkgs.nvtopPackages.amd ];

  # Extra fonts, on top of the shared set in common/
  fonts.packages = with pkgs; [
    alegreya-sans
    alegreya
    libertinus
    ibm-plex
    open-dyslexic
  ];

  system.stateVersion = "25.11";
}
