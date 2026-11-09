#!/bin/bash
# 1. Sofortiger physischer Netzwerk-Cut & Total-Sperre
ip link set eth0 down 2>/dev/null || true
ip link set eth1 down 2>/dev/null || true
nft flush ruleset 2>/dev/null || true

# 2. Akustisches Signal (optional kurzer Warnton)
(aplay /usr/share/sounds/alsa/Front_Center.wav >/dev/null 2>&1 &)

# 3. Kryptografische Prozesse radikal beenden (Kernel page_poison nullt RAM sofort)
killall -9 tor i2pd-daemon snowflake-client dnsmasq sshd 2>/dev/null || true

# 4. Page-Cache, Dentries & Inodes leeren und Caches syncen
sync
echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true

# 5. Sofortiger harter System-Shutdown
/sbin/poweroff -f || echo o > /proc/sysrq-trigger
