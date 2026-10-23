# desktop: PC fisso di casa (AMD), homelab, VM con passthrough GPU, LLM locali.
{
  config,
  pkgs,
  unstable,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./network.nix
    ./looking-glass.nix
    ./user-services.nix

    ../../modules/base.nix
    ../../modules/hyprland.nix
    ../../modules/theme.nix
    ../../modules/keyboard.nix
    ../../modules/tools.nix
    ../../modules/editors.nix
    ../../modules/dev.nix
    ../../modules/git-sync.nix
    ../../modules/documents.nix
    ../../modules/web.nix
    ../../modules/virtualization.nix

    ../../modules/homelab.nix
    ../../modules/phone.nix
    ../../modules/remote.nix
    ../../modules/maker.nix
    ../../modules/media.nix
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

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true; # needed for KMS/WLR screen capture
    openFirewall = true;
    settings.capture = "wlr"; # niente portalgrab: evita il selettore di condivisione al login
  };

  services.hyprwhspr-rs = {
    enable = true;
    package =
      (pkgs.hyprwhspr-rs.override {
        # Vulkan, not ROCm: nixpkgs passes GGML_HIPBLAS, which ggml no longer reads, so a ROCm build ends up CPU-only
        whisper-cpp = pkgs.whisper-cpp.override { vulkanSupport = true; };
      }).overrideAttrs
        (old: {
          # whisper-cli is called with a hard-coded `--language en`; auto-detect so Italian dictation isn't read as English
          postPatch = (old.postPatch or "") + ''
            substituteInPlace src/whisper/manager.rs --replace-fail '"en",' '"auto",'
            # The paste shortcut uses the legacy `dispatch sendshortcut` syntax, which a Lua Hyprland config rejects
            substituteInPlace src/input/injector.rs --replace-fail \
              'format!("dispatch sendshortcut {mods_segment}, {key}{target_segment}")' \
              'format!("dispatch hl.dsp.send_shortcut({{ mods = \"{mods_segment}\", key = \"{key}\" }})")'
          '';
        });
  };

  environment.systemPackages = [
    pkgs.nvtopPackages.amd
    config.services.hyprwhspr-rs.package # `hyprwhspr-rs record …` for hypr/scripts/dettatura-emacs.sh
  ];

  # Extra fonts, on top of the shared set in modules/theme.nix
  fonts.packages = with pkgs; [
    alegreya-sans
    alegreya
    libertinus
    ibm-plex
    open-dyslexic
  ];

  system.stateVersion = "25.11";
}
