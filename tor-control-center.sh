#!/bin/bash

DESKTOP_SCHALTER="$HOME/Desktop/tor-schalter.desktop"
REAL_SCRIPT="/opt/tor/bin/tor-control-center.sh"

# --- SYSTEM-INFOS GENERIEREN (Punkte 1, 13, 14, 15) ---
get_sys_info() {
    # 1. Systemzeit in UTC gegen Fingerprinting
    TIME_UTC=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
    
    # 15. CPU-Last berechnen
    CPU_LOAD=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
    
    # 13. Ressourcensparender RAM-Verbrauch
    RAM_USAGE=$(free -m | awk '/Mem:/ {print $3" MB / "$2" MB"}')
    
    # 14. Statusanzeige für beide Netzwerkkarten
    IP_ETH0=$(ip -4 addr show eth0 2>/dev/null | grep -oP '(?<=inet )\d+(\.\d+){3}')
    [ -z "$IP_ETH0" ] && IP_ETH0="DISCONNECTED"
    
    IP_ETH1=$(ip -4 addr show eth1 2>/dev/null | grep -oP '(?<=inet )\d+(\.\d+){3}')
    [ -z "$IP_ETH1" ] && IP_ETH1="DOWN"
    
    # Tor-Prozess-Check
    if pgrep -x tor > /dev/null; then
        TOR_STATUS="[ ACTIVE ] (Tor-Routing active)"
        FW_STATUS="[ PROTECTED ] (Ironclad Shield active)"
    else
        TOR_STATUS="[ INACTIVE ] (Gateway stopped)"
        FW_STATUS="[ UNPROTECTED ] (Cleartext leak risk!)"
    fi

    # WireGuard optionaler Status (Punkt 10)
    if ip link show wg0 >/dev/null 2>&1; then
        WG_STATUS="[ ENABLED ] (Kill-Switch armed)"
    else
        WG_STATUS="[ OPTIONAL ] (Not active)"
    fi
}

if [ "$1" == "--i2p-start" ]; then
    sudo /usr/local/sbin/antinix-tor-ctl.sh i2p-start
    sleep 1
    exit 0
fi
if [ "$1" == "--i2p-stop" ]; then
    sudo /usr/local/sbin/antinix-tor-ctl.sh i2p-stop
    sleep 1
    exit 0
fi
# --- ACTIONS BEI BUTTON-KLICK ---
if [ "$1" == "--start-action" ]; then
    if ! pgrep -x tor > /dev/null; then
        sudo /usr/local/sbin/antinix-tor-ctl.sh start
        sleep 2
        sed -i 's/^Icon=.*/Icon=network-transmit-receive/' "$DESKTOP_SCHALTER" 2>/dev/null
    fi
    exit 0
fi

if [ "$1" == "--stop-action" ]; then
    if pgrep -x tor > /dev/null; then
        sudo /usr/local/sbin/antinix-tor-ctl.sh stop
        sed -i 's/^Icon=.*/Icon=network-error/' "$DESKTOP_SCHALTER" 2>/dev/null
        sleep 1
    fi
    exit 0
fi

# --- MAIN GUI SCHLEIFE ---
while true; do
    TMP_TEXT=$(mktemp)
    get_sys_info

    {
        echo "=================================================="
        echo "  AntiNix-Panzer-Gateway Ironclad v1.11.26                     "
        echo "  \"Lightweight outside. Ironclad inside.\"        "
        echo "=================================================="
        echo ""
        echo "  SYSTEM SECURITY & TIME:"
        echo "  • System Time:         $TIME_UTC"
        echo "  • Framework Base:      antiX Linux (Systemd-free)"
        echo ""
        echo "  GATEWAY CORE STATUS:"
        echo "  • Tor Network:         $TOR_STATUS"
        echo "  • nftables Firewall:   $FW_STATUS"
        echo "  • WireGuard Tunnel:    $WG_STATUS"
        echo ""
        echo "  HARDWARE & INTERFACES:"
        echo "  • CPU Load / RAM:      $CPU_LOAD  [ $RAM_USAGE ]"
        echo "  • WAN Interface (eth0): $IP_ETH0"
        echo "  • LAN Gateway   (eth1): $IP_ETH1 -> (Workstation Target)"
        echo "=================================================="
    } > "$TMP_TEXT"

    # Yad-Fenster im legendären Monospace Matrix-Design
    yad --text-info \
        --title="AntiNix Panzer-Gateway Core" \
        --window-icon="network-vpn" \
        --width=650 \
        --height=360 \
        --fontname="Mono 11" \
        --fore="#00FF00" \
        --back="#111111" \
        --filename="$TMP_TEXT" \
        --button="START GATEWAY":10 \
        --button="STOP GATEWAY":20 \
        --button="START I2P":30 \
        --button="STOP I2P":40 \
        --button="CLOSE":1 \
        --buttons-layout=center \
        --dialog-sep

    EXIT_CODE=$?
    rm -f "$TMP_TEXT"

    if [ $EXIT_CODE -eq 10 ]; then
        bash "$REAL_SCRIPT" --start-action
    elif [ $EXIT_CODE -eq 20 ]; then
        bash "$REAL_SCRIPT" --stop-action
    elif [ $EXIT_CODE -eq 30 ]; then
        bash "$REAL_SCRIPT" --i2p-start
    elif [ $EXIT_CODE -eq 40 ]; then
        bash "$REAL_SCRIPT" --i2p-stop
    else
        break
    fi
done
