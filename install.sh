sudo mkdir -p /opt/tor/bin

sudo tee /opt/tor/bin/install.sh << 'EOF'
#!/bin/bash
# =====================================================================
# AntiNix-Panzer-Gateway: Post-Installation System Lock
# Version: Ironclad 1.11.26
# "Lightweight outside. Ironclad inside."
# =====================================================================

echo "=================================================="
echo "  Zünde Panzer-Systemhärtung für nackte Rechner... "
echo "=================================================="

# 1. Unsichere Netzwerk-Manager radikal vom System fegen
echo "-> Deinstalliere ConnMan und Avahi-AutoIP..."
sudo apt-get purge -y connman connman-ui cmst avahi-autoipd 2>/dev/null
sudo apt-get autoremove --purge -y && sudo apt-get clean

# 2. Netzwerkkarten lecksicher und statisch verdrahten
echo "-> Schreibe Netzwerk-Schnittstellen (eth0 / eth1)..."
sudo tee /etc/network/interfaces << 'INNER_EOF'
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
    address 10.152.152.1
    netmask 255.255.255.0
INNER_EOF

# 3. Erste-Start-Krypto-Trigger aktivieren (SSH-Key-Regeneration)
echo "-> Richte automatische Krypto-Schlüsselerstellung ein..."
sudo tee /etc/rc.local << 'INNER_EOF'
#!/bin/sh -e
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -A
    service ssh restart || systemctl restart ssh
fi
exit 0
INNER_EOF
sudo chmod +x /etc/rc.local

# 4. Die stählerne nftables-Firewall einbrennen
echo "-> Aktiviere die Ironclad-Firewall (nftables)..."
sudo systemctl enable nftables 2>/dev/null || sudo update-rc.d nftables defaults 2>/dev/null

echo "=================================================="
echo "  HÄRTUNG ABGESCHLOSSEN! Bitte starte das System neu: "
echo "  Befehl: sudo reboot"
echo "=================================================="
EOF

# Skript ausführbar machen
sudo chmod +x /opt/tor/bin/install.sh
