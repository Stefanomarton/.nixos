{ config, pkgs, unstable, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ./network.nix ];

  system.rebuild.enableNg = true;

  # User
  users.users.sm = {
    isNormalUser = true;
    description = "Stefano Marton";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "input" "uinput" ];
  };

  # Greetd with Hyprland
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.hyprland}/bin/Hyprland";
        user = "sm";
      };
      default_session = initial_session;
    };
  };

  # Desktop-specific: ZSH config location
  environment.etc."zshenv".text = ''
    export ZDOTDIR="$HOME"/.config/zsh
    export HISTFILE="$XDG_STATE_HOME"/zsh/history
  '';

  # Desktop-specific: Looking Glass for VM passthrough
  systemd.tmpfiles.rules =
    [ "f /dev/shm/looking-glass 0660 sm qemu-libvirtd -" ];

  # Desktop-specific: AMD GPU
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.amdgpu.opencl.enable = true;

  # Desktop-specific: Ollama with ROCm
  services.ollama = {
    package = unstable.ollama;
    enable = true;
    loadModels = [ "deepseek-r1:14b" ];
    acceleration = "rocm";
    environmentVariables = {
      HCC_AMDGPU_TARGET = "gfx1031";
      HSA_OVERRIDE_GFX_VERSION = "10.3.0";
    };
    rocmOverrideGfx = "10.3.1";
  };

  # Desktop-specific: Looking Glass client and extra VM packages
  environment.systemPackages = with pkgs; [
    looking-glass-client
    nvtopPackages.amd
  ];

  # Fonts (desktop has additional fonts)
  fonts.packages = with pkgs;
    [ julia-mono lexend alegreya-sans alegreya libertinus ibm-plex ]
    ++ builtins.filter lib.attrsets.isDerivation
    (builtins.attrValues pkgs.nerd-fonts);

  system.stateVersion = "24.05";
}
