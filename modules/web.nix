# Browser, posta, comunicazione, password.
{ pkgs, unstable, ... }:

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
