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
