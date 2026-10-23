# Browser, posta, comunicazione, password, Tasks (task e mail, dal repo tasks).
{
  pkgs,
  unstable,
  inputs,
  config,
  username,
  ...
}:

let
  browser = "chromium-browser.desktop";
  uid = toString config.users.users.${username}.uid;
in
{
  programs.chromium.enable = true;

  # Bitwarden fuori dal browser: rbw-agent tiene il vault sbloccato in memoria,
  # Super+P cerca e scrive le credenziali (rofi-rbw su rofi, tema nei dotfiles), e fa da agente SSH
  # al posto di gcr-ssh-agent. Al login ~/.local/bin/secrets-sync (dotfiles, autostart.lua di
  # Hyprland) fa il login con 2FA e scrive in RAM le chiavi API tenute nel vault.
  services.gnome.gcr-ssh-agent.enable = false;
  services.dbus.packages = [ pkgs.gcr ]; # pinentry-gnome3 fuori da GNOME
  # percorso intero: in PAM $XDG_RUNTIME_DIR potrebbe non essere ancora definita
  environment.sessionVariables.SSH_AUTH_SOCK = "/run/user/${uid}/rbw/ssh-agent-socket";

  home-manager.users.${username}.programs.rbw = {
    enable = true;
    package = unstable.rbw; # agente SSH dalla 1.14
    settings = {
      email = "sstefanomarton@gmail.com"; # server ufficiale (USA), il predefinito di rbw
      pinentry = pkgs.pinentry-gnome3;
    };
  };

  xdg.mime.defaultApplications = {
    "text/html" = browser;
    "application/xhtml+xml" = browser;
    "application/x-extension-htm" = browser;
    "application/x-extension-html" = browser;
    "application/x-extension-shtml" = browser;
    "application/x-extension-xhtml" = browser;
    "application/x-extension-xht" = browser;
    "x-scheme-handler/http" = browser;
    "x-scheme-handler/https" = browser;
    "x-scheme-handler/about" = browser;
    "x-scheme-handler/unknown" = browser;
    "x-scheme-handler/chrome" = browser;
  };

  environment.systemPackages = [
    pkgs.buku
    inputs.tasks.packages.${pkgs.stdenv.hostPlatform.system}.desktop # app Tasks (tray)
  ]
  ++ (with unstable; [
    chromium
    thunderbird
    gmailctl
    teams-for-linux
    bitwarden-desktop
    rofi-rbw-wayland
    rofi # selettore di rofi-rbw: fuzzel 1.14 non ha più --override per le sue scorciatoie
    ferdium
  ]);
}
