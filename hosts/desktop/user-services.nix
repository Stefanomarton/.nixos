# User-level timers for scripts that live in ~/.marton-drive (desktop only).
{
  inputs,
  lib,
  pkgs,
  username,
  ...
}:

let
  home = "/home/${username}";
in
{
  # MCP di agent-deck per claude.ai (agentdeck.marton.dev → tunnel desktop-agentdeck → 127.0.0.1:8095): ogni scrittura alle
  # sessioni va confermata sul telefono via ntfy. Segreti in ~/.config/{ntfy,agent-deck-mcp}/*.env.
  imports = [ inputs.agent-deck-mcp.nixosModules.default ];

  # agent-deck web anche via NetBird per l'app Android: ascolta ovunque ma la 8420 è aperta solo su
  # nb-wt0 (dalla LAN resta chiusa); col token (file locale, 600) e l'Host NetBird dichiarato.
  # Super+Del apre la UI col token letto dallo stesso file (menu.lua nei dotfiles).
  systemd.user.services.agent-deck-web.serviceConfig.ExecStart = lib.mkForce (
    "${lib.getExe inputs.agent-deck.packages.${pkgs.stdenv.hostPlatform.system}.default} web --no-tui"
    + " --listen 0.0.0.0:8420 --token-file %h/.config/agent-deck/web-token --allowed-host 100.124.206.219:8420"
  );
  networking.firewall.interfaces.nb-wt0.allowedTCPPorts = [ 8420 ];
  services.agent-deck-mcp = {
    enable = true;
    # tunnel Cloudflare suo (desktop-agentdeck): cloudflared esce, nessuna porta aperta; token in tunnel.env
    tunnel = true;
    # solo conferme firmate dall'app agent-deck (Pixel 8 associato con `agent-deck-mcp associa`): i pulsanti
    # ntfy non valgono più e senza telefono associato nessuna scrittura parte
    signedOnly = true;
    path = "${home}/.local/bin:/etc/profiles/per-user/${username}/bin:/run/current-system/sw/bin";
  };

  # Nightly: snapshot Claude Code sessions into ai-memory/raw/claude-code/ and import them into Hindsight.
  # Script and docs: ~/.marton-drive/ai-memory/tools/nightly.sh, HINDSIGHT-SETUP.md
  systemd.user.services.ai-memory-nightly = {
    description = "ai-memory: snapshot sessioni Claude Code e import in Hindsight";
    path = with pkgs; [
      bash
      coreutils
      gnugrep
      python3
    ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${home}/.marton-drive/ai-memory/tools/nightly.sh";
    };
  };
  # Timer disabled 2026-10-19: Hindsight gets only what Claude saves explicitly (retain).
  # The service stays for a manual run: systemctl --user start ai-memory-nightly
  # systemd.user.timers.ai-memory-nightly = {
  #   wantedBy = [ "timers.target" ];
  #   timerConfig = {
  #     OnCalendar = "*-*-* 03:00:00";
  #     Persistent = true;
  #   };
  # };
}
