# Browser, posta, comunicazione, password, Tasks (task e mail, dal repo tasks).
{
  pkgs,
  unstable,
  inputs,
  ...
}:

let
  browser = "chromium-browser.desktop";
in
{
  programs.chromium.enable = true;

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
    ferdium
  ]);
}
