# Base di ogni host: avvio, nix, lingua, utente, home-manager.
{
  pkgs,
  inputs,
  hostname,
  username,
  ...
}:

{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  networking.hostName = hostname;

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };
    kernelPackages = pkgs.linuxPackages_zen;
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      use-xdg-base-directories = true;

      # Fix the "download buffer is full" warning (sets it to 128MB)
      download-buffer-size = 134217728;

      substituters = [
        "https://cache.nixos.org"
        "https://yazi.cachix.org"
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
  };

  time.timeZone = "Europe/Rome";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "it_IT.UTF-8";
      LC_IDENTIFICATION = "it_IT.UTF-8";
      LC_MEASUREMENT = "it_IT.UTF-8";
      LC_MONETARY = "it_IT.UTF-8";
      LC_NAME = "it_IT.UTF-8";
      LC_NUMERIC = "it_IT.UTF-8";
      LC_PAPER = "it_IT.UTF-8";
      LC_TELEPHONE = "it_IT.UTF-8";
      LC_TIME = "it_IT.UTF-8";
    };
  };

  console.keyMap = "us-acentos";

  users.users.${username} = {
    isNormalUser = true;
    uid = 1000;
    description = "Stefano Marton";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  security.polkit.enable = true;
  services.dbus.enable = true;

  environment.etc."zshenv".text = ''
    export ZDOTDIR="$HOME"/.config/zsh
    export HISTFILE="$XDG_STATE_HOME"/zsh/history
  '';

  environment.etc."xdg/user-dirs.defaults".text = ''
    DESKTOP="$HOME/.desktop"
    DOWNLOAD="$HOME/inbox"
  '';

  systemd.settings.Manager.DefaultTimeoutStopSec = "10s";

  # Le feature aggiungono la loro parte home con home-manager.users.${username}
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.${username} = {
      home.stateVersion = "24.11";
      programs.home-manager.enable = true;
    };
  };
}
