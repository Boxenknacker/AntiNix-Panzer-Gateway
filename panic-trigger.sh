#!/bin/bash
yad --title="OPSEC PANIC KILL-SWITCH" --window-icon="process-stop" --center --width=420 --fore="#FF3333" --back="#111111" --fontname="Mono Bold 11" --text="\n  [!] WARNUNG: OPSEC NOTFALL-KILLSWITCH [!]\n\n  • Netzwerkkarten (eth0/eth1) werden sofort getrennt\n  • Tor/I2P-Schlüssel im RAM werden genullt\n  • System schaltet sich sofort hart ab\n" --button="ABBRECHEN:1" --button="KILL-SWITCH ZÜNDEN:0"

if [ $? -eq 0 ]; then
    sudo /usr/local/sbin/antinix-panic.sh
fi
