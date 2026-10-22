# Repo di config (.nixos, .dotfiles, emacs): pull al login, push a ogni commit, spegnimento bloccato con lavoro non salvato.
{ pkgs, username, ... }:

let
  home = "/home/${username}";
  repos = "${home}/.nixos ${home}/.dotfiles ${home}/.dotfiles/.config/emacs";
  deps = with pkgs; [ git gh libnotify util-linux systemd coreutils ];

  # post-commit: pubblica il branch in background; se il push fallisce avvisa (dettagli in .git/autopush.log).
  autopush = pkgs.writeShellApplication {
    name = "autopush";
    runtimeInputs = deps;
    text = ''
      git symbolic-ref -q HEAD >/dev/null || exit 0
      if [ -d "$(git rev-parse --git-path rebase-merge)" ] || [ -d "$(git rev-parse --git-path rebase-apply)" ]; then exit 0; fi
      repo=$(basename "$(git rev-parse --show-toplevel)")
      log=$(git rev-parse --git-path autopush.log)
      (
        if ! GIT_TERMINAL_PROMPT=0 flock -w 120 "$log.lock" git push --quiet >"$log" 2>&1; then
          notify-send -u critical "autopush fallito: $repo" "$(tail -n 3 "$log")" || true
        fi
      ) </dev/null >/dev/null 2>&1 &
    '';
  };

  # Login: installa l'hook, aspetta la rete, fast-forward di ogni repo.
  # Solo --ff-only: con divergenze o modifiche locali in conflitto non tocca niente e avvisa.
  pull = pkgs.writeShellApplication {
    name = "git-sync-pull";
    runtimeInputs = deps;
    text = ''
      export GIT_TERMINAL_PROMPT=0
      for r in ${repos}; do
        git -C "$r" rev-parse --git-dir >/dev/null 2>&1 || continue
        ln -sf ${autopush}/bin/autopush "$(git -C "$r" rev-parse --path-format=absolute --git-path hooks)/post-commit"
      done

      for _ in $(seq 30); do
        git -C ${home}/.nixos ls-remote --exit-code origin HEAD >/dev/null 2>&1 && break
        sleep 10
      done

      for r in ${repos}; do
        git -C "$r" rev-parse --git-dir >/dev/null 2>&1 || continue
        name=$(basename "$r")
        if ! out=$(git -C "$r" pull --ff-only --quiet 2>&1); then
          notify-send -u critical "git-sync: pull fallito in $name" "$out" || true
        elif [ -n "$(git -C "$r" status --porcelain)" ]; then
          notify-send "git-sync: $name" "modifiche non committate lasciate dall'ultima sessione" || true
        fi
      done
    '';
  };

  # Finché una repo ha modifiche non committate o commit non pushati tiene un inhibitor che blocca lo spegnimento.
  # Scavalcarlo: systemctl poweroff -i
  guard = pkgs.writeShellApplication {
    name = "git-sync-guard";
    runtimeInputs = deps;
    text = ''
      export GIT_OPTIONAL_LOCKS=0 # status in background senza prendere index.lock
      prev="" pid=""
      while :; do
        why=""
        for r in ${repos}; do
          git -C "$r" rev-parse --git-dir >/dev/null 2>&1 || continue
          name=$(basename "$r")
          n=$(git -C "$r" status --porcelain | wc -l)
          a=$(git -C "$r" rev-list --count '@{u}..' 2>/dev/null || echo 0)
          if [ "$n" -gt 0 ]; then why+="$name: $n file non committati. "; fi
          if [ "$a" -gt 0 ]; then why+="$name: $a commit non pushati. "; fi
        done
        if [ "$why" != "$prev" ]; then
          if [ -n "$pid" ]; then kill "$pid" || true; fi
          pid=""
          if [ -n "$why" ]; then
            systemd-inhibit --what=shutdown --who=git-sync --why="$why" --mode=block sleep infinity &
            pid=$!
          fi
          prev=$why
        fi
        sleep 60
      done
    '';
  };
in
{
  systemd.user.services.git-sync-pull = {
    description = "git-sync: pull delle repo di config al login";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pull}/bin/git-sync-pull";
    };
  };

  systemd.user.services.git-sync-guard = {
    description = "git-sync: blocca lo spegnimento con lavoro non committato o non pushato";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${guard}/bin/git-sync-guard";
      Restart = "always";
      RestartSec = 10;
    };
  };
}
