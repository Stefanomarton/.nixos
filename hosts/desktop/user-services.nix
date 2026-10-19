# User-level timers for scripts that live in ~/.marton-drive (desktop only).
{ pkgs, username, ... }:

let
  home = "/home/${username}";
in
{
  # Nightly: snapshot Claude Code sessions into ai-memory/raw/claude-code/ and import them into Hindsight.
  # Script and docs: ~/.marton-drive/ai-memory/tools/nightly.sh, HINDSIGHT-SETUP.md
  systemd.user.services.ai-memory-nightly = {
    description = "ai-memory: snapshot sessioni Claude Code e import in Hindsight";
    path = with pkgs; [ bash coreutils gnugrep python3 ];
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
