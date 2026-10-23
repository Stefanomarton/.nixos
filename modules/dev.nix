# Sviluppo: git, linguaggi, LSP, Claude Code.
{
  lib,
  pkgs,
  unstable,
  inputs,
  username,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;

  home = "/home/${username}";
in
{
  programs.direnv = {
    enable = true;
    silent = true;
    nix-direnv.enable = true;
    settings.global.hide_env_diff = true;
  };

  # cpm installs claude-<profile> wrappers into ~/.local/bin
  environment.localBinInPath = true;

  environment.systemPackages =
    with pkgs;
    [
      # Agenti
      inputs.claude-code.packages.${system}.claude-code
      inputs.cpm.packages.${system}.default

      # Git
      git
      lazygit
      gh
      delta
      git-lfs

      # Build
      gnumake
      cmake
      meson
      gcc
      clang
      cpio
      tree-sitter
      hyprwayland-scanner
      hyprcursor

      # Linguaggi
      python3
      nodejs_24
      bun
      typescript
      cargo
      rustc
      jre_minimal
      supabase-cli

      # LSP e formattatori
      nixd
      nixfmt
      rust-analyzer
      rustfmt
      clippy
      pyright
      typescript-language-server # LSP per il plugin typescript-lsp di Claude Code
      marksman
      taplo
      shfmt
    ]
    ++ [ unstable.herdr ];

  # agent-deck: web UI sempre attiva (http://127.0.0.1:8420), workspace "agents" con Super+Del.
  # KillMode=process: un restart non uccide il server tmux con le sessioni Claude dentro.
  systemd.user.services.agent-deck-web = {
    description = "agent-deck: web UI headless";
    wantedBy = [ "default.target" ];
    # il binario sta in ~/.local/bin (si aggiorna da solo): senza, il servizio non parte
    unitConfig.ConditionPathExists = "${home}/.local/bin/agent-deck";
    # le sessioni lanciate dal servizio cercano claude, tmux, git nel PATH di sistema
    environment.PATH = lib.mkForce "${home}/.local/bin:/etc/profiles/per-user/${username}/bin:/run/current-system/sw/bin";
    serviceConfig = {
      ExecStart = "${home}/.local/bin/agent-deck web --no-tui --listen 127.0.0.1:8420";
      KillMode = "process";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  # Aggiornamento giornaliero (lo stesso timer che agent-deck crea con update --install-timer)
  systemd.user.services.agent-deck-autoupdate = {
    description = "agent-deck: aggiornamento automatico";
    unitConfig.ConditionPathExists = "${home}/.local/bin/agent-deck";
    environment.AGENTDECK_UPDATE_TRIGGER = "timer";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${home}/.local/bin/agent-deck update --unattended --trigger timer";
    };
  };
  systemd.user.timers.agent-deck-autoupdate = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = "1h";
      Persistent = true;
    };
  };
}
