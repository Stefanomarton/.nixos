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
  agentDeck = inputs.agent-deck.packages.${system}.default;
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
    ++ [
      unstable.herdr
      agentDeck
    ];

  # agent-deck (hard fork, ~/.marton-drive/work/projects/agent-deck): web UI sempre attiva
  # (http://127.0.0.1:8420), workspace "agents" con Super+Del. Si aggiorna con `nix flake update agent-deck`.
  # KillMode=process: un restart non uccide il server tmux con le sessioni Claude dentro.
  systemd.user.services.agent-deck-web = {
    description = "agent-deck: web UI headless";
    wantedBy = [ "default.target" ];
    # le sessioni lanciate dal servizio cercano claude, tmux, git nel PATH di sistema
    environment.PATH = lib.mkForce "${home}/.local/bin:/etc/profiles/per-user/${username}/bin:/run/current-system/sw/bin";
    serviceConfig = {
      ExecStart = "${agentDeck}/bin/agent-deck web --no-tui --listen 127.0.0.1:8420";
      KillMode = "process";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  # Dopo un riavvio: riparte le sessioni morte con lo spegnimento (agent-deck fleet recover), una alla volta
  # e verificandole; le Claude riprendono la loro conversazione (--resume). Quelle fermate a mano restano ferme.
  systemd.user.services.agent-deck-recover = {
    description = "agent-deck: riavvia le sessioni interrotte dallo spegnimento";
    wantedBy = [ "default.target" ];
    after = [ "agent-deck-web.service" ];
    environment.PATH = lib.mkForce "${home}/.local/bin:/etc/profiles/per-user/${username}/bin:/run/current-system/sw/bin";
    serviceConfig = {
      Type = "oneshot";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 15"; # rete e servizi su, prima di far ripartire Claude
      ExecStart = "${agentDeck}/bin/agent-deck fleet recover --yes --spacing 8s";
    };
  };

  # Percorso stabile per gli hook di Claude (settings.json sincronizzato da cpm): agent-deck vi fissa
  # ~/.local/bin/agent-deck se porta allo stesso binario, così gli hook non cambiano a ogni aggiornamento.
  systemd.user.tmpfiles.users.${username}.rules = [
    "L+ %h/.local/bin/agent-deck - - - - /run/current-system/sw/bin/agent-deck"
  ];
}
