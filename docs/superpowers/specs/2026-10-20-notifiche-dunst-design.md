# Notifiche: dunst configurato (base)

Data: 2026-10-20. Primo di quattro pezzi (base dunst → sessioni Claude cliccabili → promemoria Tasks → eventi homelab). Questo copre solo la base.

## Problema

Le notifiche (oggi quasi tutte dalle sessioni Claude Code via kitty, più Nextcloud e autopush) sono nascoste in alto a destra, tutte uguali, spariscono prima di essere viste, non si richiamano da tastiera, e quelle del telefono (KDE Connect, soprattutto WhatsApp) sono troppe e disturbano.

## Scelta

Restare su dunst (già attivo via stylix/home-manager) e configurarlo; niente swaync né centro notifiche Quickshell finché dunst basta.

## Design

### Dove
- Comportamento di dunst: `services.dunst.settings` in `home/stylix.nix` (home-manager, vale per desktop e laptop). I colori restano quelli generati da stylix; l'accento delle urgenti viene dalla palette stylix, non da valori scritti a mano.
- Scorciatoie: `.dotfiles/.config/hypr/modules/keybindings.lua`.
- Elenco cronologia: uno script in `.dotfiles/.config/hypr/scripts/` (dunstctl + tofi + jq).

### Posizione e aspetto
- `origin = top-center`, offset verticale piccolo, larghezza ~500 px, `follow = mouse` (monitor col mouse).
- Massimo 3 notifiche visibili insieme, indicatore delle nascoste; duplicati accorpati con conteggio.

### Livelli
| Livello | Chi | Aspetto | Durata |
|---|---|---|---|
| Urgente | urgency critical dal mittente; Claude Code con «needs your input» nel testo (regola che alza l'urgenza) | bordo accento del tema | resta finché chiusa |
| Normale | resto | bordo neutro | 8 s |
| Bassa | urgency low | spenta, compatta | 3 s |

- Inattività: `idle_threshold = 120` s, le notifiche non scadono mentre non sei al PC.
- Le urgenti non vengono mai silenziate.

### Telefono (KDE Connect)
- Default: nessun popup, solo cronologia (`skip_display`).
- Eccezione: chiamate e SMS mostrati come normali.
- I nomi con cui KDE Connect presenta app/titoli vanno verificati col telefono collegato; fino ad allora le regole usano i valori previsti e vanno corrette dopo la verifica.

### Scorciatoie
| Tasto | Azione |
|---|---|
| SUPER+N | `dunstctl history-pop` (ripetuto: più indietro) |
| SUPER+SHIFT+N | `dunstctl close-all` |
| SUPER+CTRL+N | `dunstctl action` sulla prima (come clic) |
| SUPER+ALT+N | elenco cronologia in tofi; la voce scelta ricompare (`history-pop <id>`) |

## Verifica
`notify-send` di prova per: urgente, normale, bassa, finta notifica Claude «needs your input», finta notifica KDE Connect (WhatsApp e chiamata). Controllo posizione, durate, persistenza delle urgenti, cronologia e le quattro scorciatoie.

## Fuori da questo pezzo
Clic che porta alla finestra della sessione Claude; promemoria dall'app Tasks; canale homelab → desktop.
