sudo mkdir -p /opt/tor/bin

sudo tee /opt/tor/bin/install.sh << 'EOF'
#!/bin/bash
# =====================================================================
# AntiNix-Panzer-Gateway: Post-Installation System Lock & Router Setup
# Version: Ironclad 1.11.26 (Extended Security Edition)
# "Lightweight outside. Ironclad inside."
# =====================================================================

set -e # Bricht bei Fehlern sofort ab

echo "=================================================="
echo " Zünde Panzer-Systemhärtung & Plug-and-Play...   "
echo "=================================================="

# ---------------------------------------------------------------------
# STUFE 1: Systembereinigung & Paket-Vorbereitung
# ---------------------------------------------------------------------
echo "[*] Deinstalliere ungeschützte Netzwerk-Manager..."
sudo apt-get purge -y connman connman-ui cmst avahi-autoipd 2>/dev/null || true
sudo apt-get autoremove --purge -y && sudo apt-get clean

echo "[*] Bereinige Paketverwaltung und lade Systemkomponenten..."
# Fix für fehlende Cache-Verzeichnisse im Live-System
sudo mkdir -p /var/cache/apt-show-versions

# Deaktiviere das ungenutzte MX-Trixie-Repository (Vermeidung von 404-Fehlern)
sudo sed -i 's|^deb https://mxrepo.com|# deb https://mxrepo.com|g' /etc/apt/sources.list.d/* 2>/dev/null || true

# System-Update und Installation von Schlüssel-Tools (dnsmasq, python3-pip, haveged, secure-delete)
sudo apt-get update -o APT::Update::Post-Invoke-Success=""
sudo apt-get install dnsmasq python3-pip haveged secure-delete -y

# ---------------------------------------------------------------------
# STUFE 2: Netzwerkkarten lecksicher und statisch verdrahten
# ---------------------------------------------------------------------
echo "[*] Schreibe permanente Netzwerk-Schnittstellen (eth0 / eth1)..."
sudo tee /etc/network/interfaces << 'INNER_EOF'
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
    address 10.152.152.10
    netmask 255.255.255.0
INNER_EOF

# Kiosk-Konfiguration für dnsmasq schreiben (DHCP für unbegrenzt viele VMs)
sudo tee /etc/dnsmasq.conf << 'INNER_EOF'
interface=eth1
bind-interfaces
dhcp-range=10.152.152.50,10.152.152.150,255.255.255.0,12h
port=0
INNER_EOF

# ---------------------------------------------------------------------
# STUFE 3: SSH-First-Boot-Wizard & Entropy-Booster einrichten
# ---------------------------------------------------------------------
echo "[*] Generiere Krypto-Sicherheits-Wizard (First-Boot)..."

sudo tee /usr/local/bin/antinix-ssh-wizard.sh << 'INNER_EOF'
#!/bin/bash
# AntiNix-Gateway SSH First-Boot Wizard & Entropy Booster

# 1. LIVE-MODUS-PRÜFUNG (Bricht auf der Live-ISO sofort lautlos ab)
if grep -E -q "boot=live|media=|antiX=" /proc/cmdline; then
    exit 0
fi

MARKER_FILE="/var/lib/antinix_ssh_configured"

# 2. PRÜFUNG OB BEREITS KONFIGURIERT
if [ -f "$MARKER_FILE" ]; then
    exit 0
fi

# 3. AUTOMATISCHE ENTROPIE-EINSPEISUNG FÜR DEN ERSTEN START
# Zwingt haveged den Zufallspool sofort einmalig randvoll zu knallen, beendet sich danach selbst
sudo haveged -w 1024 --once 2>/dev/null

# 4. GRAFISCHES BENUTZER-INTERFACE (YAD)
yad --warning --title="AntiNix Security Wizard" \
    --text="<b>SYSTEM ERFOLGREICH INSTALLIERT</b>\n\nAus Sicherheitsgründen müssen die SSH-Hostschlüssel dieses installierten Gateways nun neu generiert werden.\n\nKlicke auf 'Generieren', um deine einzigartigen Krypto-Schlüssel lecksicher zu erzeugen." \
    --button="Schlüssel generieren:0" --width=420 --image="dialog-password" --buttons-layout=center

if [ $? -eq 0 ]; then
    # Löscht alte Keys und erzeugt dank vollem Entropie-Pool sofort einzigartige Schlüssel
    sudo rm -f /etc/ssh/ssh_host_*_key*
    sudo dpkg-reconfigure openssh-server

    # SSH-Dienst permanent aktivieren und starten
    sudo update-rc.d ssh enable 2>/dev/null
    sudo service ssh restart 2>/dev/null || sudo service openssh restart

    # Marker-Datei schreiben, damit dieses Skript nie wieder anspringt
    sudo touch "$MARKER_FILE"

    yad --info --title="Erfolg" --text="Die einzigartigen SSH-Hostschlüssel wurden erfolgreich generiert!\nDas Gateway ist ab sofort sicher erreichbar." --button="OK:0" --width=350 --buttons-layout=center
fi
INNER_EOF

sudo chmod +x /usr/local/bin/antinix-ssh-wizard.sh

# Globalen Session-Autostart für den Wizard hinterlegen
sudo tee /etc/xdg/autostart/antinix-ssh.desktop << 'INNER_EOF'
[Desktop Entry]
Type=Application
Name=AntiNix SSH Wizard
Exec=/usr/local/bin/antinix-ssh-wizard.sh
Terminal=false
Icon=dialog-password
Categories=System;Security;
INNER_EOF

# ---------------------------------------------------------------------
# STUFE 4: OnionShare-CLI & Integrierter Steuerungssicherheits-Filter
# ---------------------------------------------------------------------
echo "[*] Baue OnionShare-Infrastruktur und Whitelist-Proxy auf..."

# Installation der native OnionShare-CLI für das Gateway
pip3 install --user onionshare-cli --break-system-packages 2>/dev/null || pip3 install --user onionshare-cli
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

# Schreiben des Python-Schutzfilters (Unser maßgeschneiderter onion-grater)
sudo tee /usr/local/bin/antinix-control-filter.py << 'INNER_EOF'
import socket
import threading

LISTEN_IP = "10.152.152.10"
LISTEN_PORT = 9051
TOR_PORT = 9051

def handle_client(client_socket):
    try:
        tor_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        tor_socket.connect(("127.0.0.1", TOR_PORT))
    except Exception:
        client_socket.close()
        return

    try:
        with open("/opt/tor/var/lib/tor/control_auth_cookie", "rb") as f:
            cookie_data = f.read().hex()
        tor_socket.send(f"AUTHENTICATE {cookie_data}\r\n".encode())
        tor_socket.recv(1024)
    except Exception:
        pass

    def forward(source, destination, is_request):
        while True:
            try:
                data = source.recv(4096)
                if not data:
                    break
                if is_request:
                    cmd = data.decode('utf-8', errors='ignore').strip()
                    if cmd.startswith("AUTHENTICATE"):
                        source.send(b"250 OK\r\n")
                        continue
                    allowed = False
                    for valid_cmd in ["ADD_ONION", "DEL_ONION", "GETCONF", "SIGNAL", "QUIT"]:
                        if cmd.startswith(valid_cmd):
                            allowed = True
                            break
                    if not allowed:
                        source.send(b"510 Command filtered for anonymity protection.\r\n")
                        continue
                destination.send(data)
            except Exception:
                break
        source.close()
        destination.close()

    threading.Thread(target=forward, args=(client_socket, tor_socket, True), daemon=True).start()
    threading.Thread(target=forward, args=(tor_socket, client_socket, False), daemon=True).start()

def main():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind((LISTEN_IP, LISTEN_PORT))
    server.listen(5)
    while True:
        client_sock, _ = server.accept()
        threading.Thread(target=handle_client, args=(client_sock,), daemon=True).start()

if __name__ == "__main__":
    main()
INNER_EOF

sudo chmod +x /usr/local/bin/antinix-control-filter.py

# ---------------------------------------------------------------------
# STUFE 5: Kiosk-Hardening & Anti-Forensik
# ---------------------------------------------------------------------
echo "[*] Verriegele grafische Oberfläche und aktiviere RAM-Protection..."

# USB-Automount-Dienste komplett unschädlich machen (Schutz vor BadUSB)
sudo systemctl stop devmon@user.service 2>/dev/null || true
sudo systemctl disable devmon@user.service 2>/dev/null || true
sudo chmod 000 /usr/bin/devmon 2>/dev/null || true
sudo chmod 000 /usr/bin/udevil 2>/dev/null || true

# Tastenkombinationen in IceWM sperren (Verhindert das Öffnen von Run-Commandern)
mkdir -p ~/.icewm/
cat << 'INNER_EOF' >> ~/.icewm/preferences
KeySysFetchMenu=""
KeySysRun=""
KeySysWindowMenu=""
WinListFilterShowApps=0
INNER_EOF
echo 'key "Alt+F2" id0' >> ~/.icewm/keys

# Desktop-Rechtsklick und Hintergrund-Symbole komplett deaktivieren
find ~/.config/rox.sourceforge.net/ROX-Filer/ -type f -name "pb_*" -exec sed -i 's/<pinboard.*/<pinboard>/g' {} +

# Standardbrowser-Shortcuts aus dem Startmenü verbannen (Sicherheits-Policy)
sudo rm -f /usr/share/applications/firefox*.desktop /usr/share/applications/chromium*.desktop /usr/share/applications/badwolf*.desktop

# Anti-Forensik RAM-Wiping über SysVinit/Runit aktivieren
sudo update-rc.d antinix-ram-wipe defaults 2>/dev/null || true

# ---------------------------------------------------------------------
# STUFE 6: Die stählerne nftables-Firewall & Autostarts einbrennen
# ---------------------------------------------------------------------
echo "[*] Aktiviere die Ironclad-Firewall (nftables) und Boot-Dienste..."
sudo systemctl enable nftables 2>/dev/null || sudo update-rc.d nftables defaults 2>/dev/null

# Permanente Autostarts sauber in die rc.local einfrieren
sudo tee /etc/rc.local << 'INNER_EOF'
#!/bin/sh -e

# --- AntiNix-Panzer-Gateway: PLUG-AND-PLAY DHCP AUTOSTART ---
ip link set eth1 up
ip addr add 10.152.152.10/24 dev eth1 2>/dev/null
service dnsmasq restart 2>/dev/null

# --- AntiNix-Panzer-Gateway: TOR-CONTROL-FILTER START ---
python3 /usr/local/bin/antinix-control-filter.py &

exit 0
INNER_EOF

sudo chmod +x /etc/rc.local

echo "=================================================="
echo " HÄRTUNG & ARCHITEKTUR-SETUP REPRODUZIERBAR BEREIT!"
echo " Bitte starte das System neu: sudo reboot         "
echo "=================================================="
EOF


