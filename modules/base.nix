# Base di ogni host: avvio, nix, lingua, utente, home-manager.
{
  config,
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
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
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
    extraGroups = [ "wheel" ];
  };

  security.polkit.enable = true;
  services.dbus.enable = true;

  # Via PAM: le vedono anche le app di Hyprland e i servizi utente, non solo zsh.
  # Tutto da $HOME: in PAM un riferimento a un'altra variabile dipende dall'ordine.
  environment.sessionVariables = {
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_DESKTOP_DIR = "$HOME/";
    NPM_CONFIG_INIT_MODULE = "$HOME/.config/npm/config/npm-init.js";
    NPM_CONFIG_CACHE = "$HOME/.cache/npm";
    NPM_CONFIG_TMP = "/run/user/${toString config.users.users.${username}.uid}/npm";
    ANDROID_USER_HOME = "$HOME/.local/share/android";
    _JAVA_OPTIONS = "-Djava.util.prefs.userRoot=$HOME/.config/java";
    NODE_REPL_HISTORY = "$HOME/.local/share/node_repl_history";
    LESSHISTFILE = "$HOME/.cache/less/history";
    GTK2_RC_FILES = "$HOME/.config/gtk-2.0/gtkrc";
    GNUPGHOME = "$HOME/.local/share/gnupg";
    CUDA_CACHE_PATH = "$HOME/.cache/nv";
    CARGO_HOME = "$HOME/.local/share/cargo";
    STARSHIP_CONFIG = "$HOME/.config/starship.toml";
    NUGET_PACKAGES = "$HOME/.cache/NuGetPackages";
    GOPATH = "$HOME/.local/share/go";
    MYPY_CACHE_DIR = "$HOME/.cache/mypy";
    TEXMFVAR = "$HOME/.cache/texlive/texmf-var";
    DOTNET_CLI_HOME = "$HOME/.local/share/dotnet";
  };

  environment.etc."zshenv".text = ''
    export ZDOTDIR="$HOME"/.config/zsh
    export HISTFILE="$XDG_STATE_HOME"/zsh/history
  '';
  # zsh non crea la cartella della history: senza, su un'installazione nuova non salva nulla
  systemd.tmpfiles.rules = [ "d /home/${username}/.local/state/zsh 0700 ${username} users -" ];

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
