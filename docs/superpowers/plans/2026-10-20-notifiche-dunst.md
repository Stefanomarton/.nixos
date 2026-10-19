# Notifiche dunst (base) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** dunst in alto al centro, tre livelli (urgenti persistenti), telefono solo in cronologia salvo chiamate/SMS, richiamo da tastiera.

**Architecture:** Comportamento in `services.dunst.settings` (home-manager, `~/.nixos/home/stylix.nix`; i colori restano quelli di stylix, che già distingue le urgenze). Scorciatoie e picker della cronologia nei dotfiles Hyprland. Le regole si provano prima del rebuild caricando il dunstrc generato con `dunstctl reload <file>`.

**Tech Stack:** NixOS + home-manager + stylix, dunst 1.13.2, Hyprland (config Lua), tofi, jq.

## Global Constraints

- Spec: `docs/superpowers/specs/2026-10-20-notifiche-dunst-design.md`.
- `origin = top-center`, larghezza 500, max 3 visibili, timeout bassa 3 s / normale 8 s / urgente 0 (resta), `idle_threshold = 120`.
- Claude Code: appname `kitty`, body contiene `needs your input` → urgenza critical.
- Telefono: appname che contiene `connect` (KDE Connect) → `skip_display`; eccezioni chiamate/SMS mostrate. Nomi da verificare col telefono collegato.
- Tasti: SUPER+N history-pop, SUPER+SHIFT+N close-all, SUPER+CTRL+N action, SUPER+ALT+N picker tofi.
- Nessun colore scritto a mano.

---

### Task 1: Regole dunst + verifica automatica

**Files:**
- Create: `~/.nixos/tests/notifiche.sh`
- Modify: `~/.nixos/home/stylix.nix` (blocco `services.dunst`)

**Interfaces:**
- Produces: dunstrc con le sezioni `claude_attende`, `telefono*`; `tests/notifiche.sh` (exit 0 = regole ok) usato anche nel Task 3.

- [ ] **Step 1: Scrivi la verifica**

`~/.nixos/tests/notifiche.sh` (eseguibile):

```bash
#!/usr/bin/env bash
# Verifica le regole dunst (home/stylix.nix) sul dunst in esecuzione. Chiude le notifiche a schermo.
set -u
tag="test-$$" fail=0
send() { notify-send "$@"; sleep 0.4; }
hist() { dunstctl history | jq -r --arg s "$1" "[.data[0][] | select(.summary.data==\$s)] | $2"; }
check() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1: atteso '$3', avuto '$2'"; fail=1; fi; }

dunstctl close-all; sleep 0.3
send -a kitty "Claude Code $tag" "sessione x needs your input: domanda"
send -a "KDE Connect" "WhatsApp $tag" "Mario: ciao"
check "whatsapp senza popup" "$(dunstctl count displayed)" "1"
send -a "KDE Connect" "Incoming call $tag" "Mario"
check "chiamata a schermo" "$(dunstctl count displayed)" "2"
dunstctl close-all; sleep 0.3
check "claude in attesa -> critical" "$(hist "Claude Code $tag" '.[0].urgency.data')" "CRITICAL"
check "whatsapp in cronologia" "$(hist "WhatsApp $tag" 'length')" "1"

for id in $(dunstctl history | jq -r --arg t "$tag" '.data[0][] | select(.summary.data | endswith($t)) | .id.data'); do
  dunstctl history-rm "$id"
done
exit $fail
```

- [ ] **Step 2: Eseguila e verifica che fallisca**

Run: `chmod +x ~/.nixos/tests/notifiche.sh && ~/.nixos/tests/notifiche.sh`
Expected: `FAIL whatsapp senza popup`, `FAIL claude in attesa -> critical` (la config attuale non ha regole), exit 1.

- [ ] **Step 3: Configura dunst**

In `~/.nixos/home/stylix.nix` sostituisci il blocco `dunst = { ... };` con:

```nix
    dunst = {
      enable = true;
      settings = {
        global = {
          follow = "mouse";
          origin = "top-center";
          offset = "(0, 40)";
          width = 500;
          notification_limit = 3;
          indicate_hidden = true;
          stack_duplicates = true;
          hide_duplicate_count = false;
          idle_threshold = 120; # lontano dal PC: non scadono
          history_length = 100;
          sticky_history = true;
          frame_width = 2;
          mouse_left_click = [
            "do_action"
            "close_current"
          ];
        };
        urgency_low.timeout = 3;
        urgency_normal.timeout = 8;
        urgency_critical.timeout = 0; # resta finché la chiudi

        # Regole: le sezioni escono in ordine alfabetico e dunst applica l'ultima che combacia.
        claude_attende = {
          appname = "kitty";
          body = "*needs your input*";
          urgency = "critical";
        };
        # Telefono (KDE Connect): solo cronologia, tranne chiamate e SMS. Nomi da verificare col telefono.
        telefono = {
          appname = "*[Cc]onnect*";
          skip_display = true;
        };
        telefono_chiamate = {
          appname = "*[Cc]onnect*";
          summary = "*[Cc]all*";
          skip_display = false;
        };
        telefono_chiamate_it = {
          appname = "*[Cc]onnect*";
          summary = "*hiamat*";
          skip_display = false;
        };
        telefono_messaggi = {
          appname = "*[Cc]onnect*";
          summary = "Messag*";
          skip_display = false;
        };
        telefono_sms = {
          appname = "*[Cc]onnect*";
          summary = "*SMS*";
          skip_display = false;
        };
      };
    };
```

- [ ] **Step 4: Carica il dunstrc generato e riesegui la verifica**

Run:
```bash
cd ~/.nixos && git add home/stylix.nix tests/notifiche.sh
f=$(nix build --no-link --print-out-paths ".#nixosConfigurations.desktop.config.home-manager.users.sm.xdg.configFile.\"dunst/dunstrc\".source")
dunstctl reload "$f" && ~/.nixos/tests/notifiche.sh
```
Expected: quattro righe `ok`, exit 0. Controllo a vista: `notify-send prova` compare in alto al centro.

- [ ] **Step 5: Commit**

```bash
cd ~/.nixos && git commit -m "dunst: in alto al centro, urgenti persistenti, Claude in attesa urgente, telefono solo in cronologia salvo chiamate/SMS" -- home/stylix.nix tests/notifiche.sh
```

### Task 2: Scorciatoie e cronologia in tofi

**Files:**
- Create: `~/.dotfiles/.config/hypr/scripts/notifiche-cronologia.sh`
- Modify: `~/.dotfiles/.config/hypr/modules/keybindings.lua` (in coda)

**Interfaces:**
- Consumes: `dunstctl` (history JSON: `.data[0][]` con `.id.data`, `.appname.data`, `.summary.data`, `.body.data`).

- [ ] **Step 1: Script del picker**

`~/.dotfiles/.config/hypr/scripts/notifiche-cronologia.sh` (eseguibile):

```bash
#!/usr/bin/env bash
# Cronologia dunst in tofi: la notifica scelta torna a schermo.
sel=$(dunstctl history | jq -r '.data[0][] | "\(.id.data)\t\(.appname.data): \(.summary.data) — \(.body.data | gsub("\n"; " ") | .[0:80])"' \
  | tofi --prompt-text "notifiche: ") || exit 0
[ -n "$sel" ] && dunstctl history-pop "${sel%%$'\t'*}"
```

- [ ] **Step 2: Verifica lo script senza tofi**

Run: `notify-send prova-picker "x"; dunstctl close-all; dunstctl history | jq -r '.data[0][0] | "\(.id.data)\t\(.summary.data)"'`
Expected: `<id>	prova-picker`; poi `dunstctl history-pop <id>` la rimette a schermo.

- [ ] **Step 3: Scorciatoie**

In coda a `~/.dotfiles/.config/hypr/modules/keybindings.lua`:

```lua
-- Notifiche (dunst)
hl.bind(mainMod .. " + N",         hl.dsp.exec_cmd("dunstctl history-pop"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("dunstctl close-all"))
hl.bind(mainMod .. " + CTRL + N",  hl.dsp.exec_cmd("dunstctl action"))
hl.bind(mainMod .. " + ALT + N",   hl.dsp.exec_cmd("~/.config/hypr/scripts/notifiche-cronologia.sh"))
```

- [ ] **Step 4: Ricarica e controlla**

Run: `hyprctl reload && hyprctl configerrors && hyprctl binds -j | jq -r '.[] | select(.key=="N") | "\(.modmask) \(.arg)"'`
Expected: nessun errore; quattro righe con i comandi sopra.

- [ ] **Step 5: Commit** (l'autopush pubblica)

```bash
cd ~/.dotfiles && git add .config/hypr/scripts/notifiche-cronologia.sh .config/hypr/modules/keybindings.lua && git commit -m "hypr: SUPER+N per richiamare, chiudere, aprire e sfogliare le notifiche dunst"
```

### Task 3: Rebuild e verifica finale

- [ ] **Step 1:** Stefano esegue `sudo nixos-rebuild switch --flake ~/.nixos#desktop` (dunst riparte col dunstrc definitivo).
- [ ] **Step 2:** Run `~/.nixos/tests/notifiche.sh` — Expected: tutto `ok`.
- [ ] **Step 3:** Prova manuale dei quattro tasti; `notify-send -u critical prova` resta finché chiusa; `notify-send -u low prova` sparisce in ~3 s.
- [ ] **Step 4:** Col telefono collegato: `dunstctl history | jq '.data[0][] | select(.appname.data|test("onnect"))'` per leggere appname/summary reali di WhatsApp, chiamate, SMS; correggere le regole `telefono_*` se diversi e ripetere il Task 1 Step 4.
