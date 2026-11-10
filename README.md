# 🛡️ AntiNix-Panzer-Gateway — Ironclad

**"Lightweight outside. Ironclad inside."**

<img width="1600" height="775" alt="Github" src="https://github.com/user-attachments/assets/3d6b9d03-81c7-4a53-895b-8fd11c37506c" />

An ultra-lightweight, systemd-free, heavily hardened **Tor & I2P Gateway** built on top of the rock-solid antiX Linux (Debian stable base). It acts as an impenetrable digital armor, isolating and routing all network traffic from any connected Workstation securely through the Tor network—with automated Snowflake censorship circumvention and optional parallel I2P routing.

Inspired by Whonix, but engineered completely without systemd overhead to be faster, more secure, and extremely resource-efficient.

---

## ⚙️ Technical Specifications

* **Kernel:** Hardened Linux Kernel (64-Bit Intel/AMD)
* **RAM:** 512 MB minimum (Runs smoothly at ~250–300 MB), 1024 MB recommended
* **Storage:** ~5.64 GB Net core size (10 GB Virtual Disk Space recommended)
* **CPU:** 1 Core allocation is highly sufficient
* **Init System:** SysVinit / Runit (100% Systemd-Free)
* **Desktop Environment:** Highly optimized IceWM (AntiNix Custom Cyberpunk Theme)
* **Virtualization:** Universally compatible with VirtualBox, VMware, KVM, and Bare Metal
* **Security Isolation:** VirtualBox Guest Additions are **intentionally omitted** to eliminate host-leak risks and prevent VM-escape exploits

---

## 🔒 Key Features (Ironclad Specifications)

### 1. Network & Leak Protection
* **Next-Gen Firewall Architecture (eBPF/XDP & Fail-Closed nftables):** Implements an **eBPF/XDP** packet shield on `eth0` combined with a strict **fail-closed `nftables` ruleset** (`forward drop`, zero `MASQUERADE` NAT). All traffic from the Workstation (`eth1`) is forced in kernel-space through the local Tor `TransPort` (`9040`) and `DNSPort` (`5353`), making clearnet IP or DNS leaks mathematically impossible.
* **Native Brute-Force Protection:** Built-in rate limiting and dynamic IP sets directly inside kernel-space, eliminating the need for heavy background daemons like Fail2ban.
* **Strict UID Service Isolation:** Network daemons are completely decoupled from the desktop session (`user`, UID `1000`). Only dedicated system users (`debian-tor` / UID `107` and `i2pd` / UID `105`) are permitted by `nftables` (`meta skuid`) to initiate outbound WAN connections on `eth0`. Desktop processes and root shell tools are blocked from direct clearnet access.
* **Automated Censorship Circumvention (Snowflake Auto-Fallback):** Upon login via **Slimski PAM** and `dhcpcd` hooks, Tor (`/opt/tor`) attempts a direct bootstrap first. If direct Tor connections are blocked by DPI or restrictive firewalls, the gateway automatically switches to **Snowflake (WebRTC)** using privacy-respecting STUN servers (Mozilla & Freifunk, zero Google dependencies).
* **Optional I2P Overlay Routing (`i2pd` C++ Daemon):** Includes a lightweight, zero-Java C++ `i2pd` router (~35 MB RAM footprint) toggleable on demand via the Command Center GUI. Exposes isolated HTTP (`10.152.152.10:4444`) and SOCKS5 (`10.152.152.10:4447`) proxies exclusively to the Workstation (`eth1`), allowing simultaneous `.i2p` Eepsite access alongside transparent Tor routing.
* **Fixed Network Interface Names:** Interfaces are hardcoded as `eth0` (External WAN) and `eth1` (Internal Workstation LAN) via kernel parameters, eliminating interface naming race-conditions.
* **WireGuard Integration:** Ready for optional VPN chaining (Before/After Tor) featuring an integrated Kill-Switch to drop all traffic instantly if the VPN tunnel disconnects.
* **UTC System Time:** Forces Coordinated Universal Time (UTC) to eliminate hardware-level time-zone fingerprinting by malicious scripts.

### 2. Kernel & OS Hardening
* **Hardened Kernel Baseline:** Optimized `sysctl` configurations aggressively protecting against IP spoofing, MITM routing manipulation (ICMP redirects), and local side-channel vulnerabilities.
* **Advanced Memory (RAM) Protection:** Kernel-enforced memory poisoning (`page_poison=1 slub_debug=P`) to prevent unauthorized memory dumping and cold-boot scraping of sensitive cryptographic data during runtime.
* **Strict User & Session Isolation:** Hardened with `libpam-tmpdir` to securely isolate temporary files per user session and prevent cross-user data leaks.
* **USB BadUSB & Mass-Storage Hardening:** Blocks unauthorized USB mass-storage auto-mounting by default to prevent physical BadUSB/RubberDucky payload injection.
* **Enforced Security Compliance:** Integrated `libpam-pwquality` enforcing a strict minimum 12-character strong password policy upon user configuration changes.
* **Professional Auditing:** This entire system baseline has been fully audited and verified using **Lynis (Security Auditing Tool)** to ensure enterprise-grade security compliance.

### 3. Custom Command Center, UI & OPSEC Emergency Controls
* **AntiNix Panzer-Gateway Core GUI (Multi-Protocol Control):** In-house YAD control dashboard allowing one-click **START/STOP** management for both the **Tor Gateway** and the optional **I2P (`i2pd`) Router** via privilege-separated root wrappers.
* **Symmetrical Dual-Engine Live Monitors (Conky):** Real-time, non-overlapping dual panels pinned flat to the desktop edges (`top_left` and `top_right`) with unified neon-green graphs (`#55FE23`). The left audit panel distinguishes between **`DIREKT (STANDARD)`**, **`SNOWFLAKE BRIDGE`**, and **`I2P ROUTER AKTIV (PORT 4444/4447)`** with zero-overhead kernel process checks.
* **Live Security Audit & Intrusion Detector:** Parses system authentication strings and `nftables` kernel buffers in real-time, triggering a sharp visual **`[ ALARM ]`** accompanied by an **audible warning tone (ALSA beep)** upon detecting unauthorized access or firewall block events.
* **OPSEC Emergency Panic Kill-Switch (`PANIC KILL-SWITCH`):** Accessible directly from the desktop via a high-contrast tactical trigger overlay (requiring a single confirmation click or `Enter` to prevent accidental activation):
  * **Immediate Physical Network Cut:** Executes `ip link set eth0 down` and `ip link set eth1 down` alongside an instant `nftables` ruleset flush, physically severing both WAN and Workstation interfaces within milliseconds.
  * **Cryptographic Process Termination & RAM Sanitization:** Force-kills all active network and encryption daemons (`tor`, `i2pd-daemon`, `snowflake-client`, `dnsmasq`, `sshd`) via `SIGKILL` (`killall -9`) and flushes kernel page caches (`drop_caches`). Combined with `page_poison=1 slub_debug=P`, freed memory pages containing session keys are immediately overwritten with poison bytes.
  * **Zero-Delay Hard Poweroff:** Bypasses standard init service timeouts via `poweroff -f` / `SysRq` for instant hardware shutdown.
* **Hardened Custom Login (Slimski):** Seamless integration with the gateway aesthetics. All interactive user inputs (`user` / password fields) are dynamically forced into a muted tactical dark green (`#1E5616`), removing default blue highlights.

---

## 🚀 Quick-Start Guide (Plug & Play Deployment)

### 1. Virtual Machine Wiring (Host Setup)
* **Gateway VM (`AntiNix Panzer-Gateway`):**
  * **Adapter 1 (`eth0` - WAN):** Set to **NAT** or **Bridged** (Internet uplink).
  * **Adapter 2 (`eth1` - LAN):** Set to **Internal Network** (e.g., `PanzerNet`).
* **Workstation VM (Any OS: Linux, Windows, BSD):**
  * **Adapter 1 (Single NIC only):** Set to the exact same **Internal Network** (`PanzerNet`). *Never attach a second WAN adapter to the Workstation.*

### 2. Booting & Activating the Gateway
1. **Boot the Gateway VM:** The kernel immediately loads the **eBPF/XDP** packet shield and **fail-closed `nftables` rules** before login. No network traffic can leave the machine yet.
2. **Log in via Slimski:** Enter your credentials. PAM automatically wakes `eth0`, fetches a WAN IP via `dhcpcd`, and launches Tor under the isolated `debian-tor` user.
3. **Verify Left Conky Audit Panel:**
   * `[ OK ] TOR ANONYMISIERUNG LIVE` → Tor is active.
   * `TOR-MODUS: DIREKT (STANDARD)` or `SNOWFLAKE BRIDGE` → Automatic censorship circumvention is active.
   * `[ OK ] DHCP-SERVER BEREIT` → Ready to assign an IP to your Workstation on `eth1`.

### 3. Workstation Configuration (Tor & Optional I2P)
* **Standard Tor Routing (Zero-Config / Automatic):**
  * Set your Workstation network adapter to **DHCP** (or assign static IP `10.152.152.11` / Netmask `255.255.255.0` / Gateway `10.152.152.10` / DNS `10.152.152.10`).
  * **Done.** All TCP traffic and DNS queries from the Workstation are transparently forced through Tor (`TransPort 9040` / `DNSPort 5353`).
* **Optional I2P Overlay Routing (`.i2p` Eepsites):**
  1. On the Gateway desktop, open **Tor Gateway Monitor** and click **`START I2P`**.
  2. Wait until the left Conky shows `[ OK ] I2P ROUTER AKTIV (PORT 4444/4447)`.
  3. In your Workstation browser (e.g., secondary browser profile), configure manual proxy settings:
     * **HTTP Proxy:** `10.152.152.10` | **Port:** `4444`
     * **SOCKS5 Host:** `10.152.152.10` | **Port:** `4447`
  4. You can now browse `.i2p` sites while all non-proxy traffic continues routing securely through Tor.

### 4. Desktop Command Center Cheat-Sheet
* **QUICKSTART.txt:** Offline desktop cheat-sheet with full wiring and proxy instructions.
* **Tor Gateway Monitor:** Start/Stop **Tor** and the optional **I2P (`i2pd`)** daemon with one click.
* **SSH-Verbindung:** Launches the interactive crypto-key wizard for secure administrative access.
* **PANIC KILL-SWITCH (Red Triangle Icon):** Immediate OPSEC emergency override — physically cuts `eth0`/`eth1`, force-kills all crypto processes, triggers kernel RAM poisoning, and executes an instant hard poweroff.

---

## 📥 Download & Checksum Verification

* **Official Download (Live ISO / Installer):** [Download `antinix-panzer-gateway.iso` (2.03 GB via MEGA)](https://mega.nz/file/WCRyhRyJ#vaOi5emHFcO5nc9bGgFU3aXAyDwhvEnBv2RjPs5hS4g)

| File Name | Checksum Type | Hash Value |
| :--- | :--- | :--- |
| `antinix-panzer-gateway.iso` | **MD5** | `d5c6905255c9258eb353e639afcab58c` |
| `antinix-panzer-gateway.iso` | **SHA256** | `ee62dd65b1e83ec9cdcd4893407e1bca06848375f030ffb038cd4445cbd3f854` |
| `antinix-panzer-gateway.iso` | **SHA512** | `da0c84f53a8acf7548b979152ed4f3c6a71abeaeb3ff81526fb9c21550c021acf30e83806dd5049cf1cd884af90481ab4a54b246995b7e0ee47120872aca1b22` |

### Verification Commands:
* **Linux:** `md5sum`, `sha256sum`, and `sha512sum antinix-panzer-gateway.iso`
* **Windows (PowerShell):** `Get-FileHash .\antinix-panzer-gateway.iso -Algorithm [MD5|SHA256|SHA512]`

---

## 🚀 Quick Start & Deployment

To avoid manual partitioning and bypass virtual environment NVRAM constraints, we highly recommend using the pre-configured appliance (.ova):

1. Download the `.ova` file (oder installiere alternativ via `.iso`) von dem **Releases** Tab und verifiziere den Hash.
2. In VirtualBox, gehe auf **Datei** ➔ **Appliance importieren** und wähle die Datei aus.
3. Setze die **MAC-Adressen-Richtlinie** auf **"Neue MAC-Adressen für alle Netzwerkkarten generieren"**, um eine netzwerktechnische Isolierung zu garantieren.
4. Stelle sicher, dass der Netzwerkadapter deiner anzubindenden Workstation-VM auf **Internes Netzwerk** gestellt ist und auf das Gateway-Interface (`eth1`) zugreift.
5. **Installing to Disk (Optional):** To install the Gateway permanently onto a virtual or physical drive, open a terminal and run **`sudo minstall`** 


---

### 🔑 Default Credentials
* **Username:** `user`
* **Password:** `changeme`

> [!IMPORTANT]
> **DO NOT CHANGE THE USERNAME (`user`)!** 
> The entire hardening framework, native firewall scripts, isolated Tor paths, and Conky desktop monitoring modules are strictly hardcoded to the environment and paths of the default user (`/home/user/`). Changing the username will completely break the gateway security architecture and network routing.

> [!WARNING]
> Change **only** the default password immediately upon your first login using the `passwd` command! The system will enforce a strong password compliance policy (minimum 12 characters, mixing character classes).

---

## 🛡️ Physical Security Hardening (Optional)

By default, the bootloader (GRUB) is not password-protected to allow for easy image deployment. If your gateway is located in a physically insecure environment, we highly recommend protecting GRUB to prevent unauthorized root access via boot parameter manipulation:

1. Generate a password hash:
   ```bash
   sudo grub-mkpasswd-pbkdf2
   ```
2. Append the generated hash to `/etc/grub.d/40_custom`:
   ```text
   set superusers="root"
   password_pbkdf2 root <YOUR_GENERATED_HASH_HERE>
   ```
3. Update your bootloader:
   ```bash
   sudo update-grub
   ```

---

## 🛠️ ISO Installation & Troubleshooting Notice

If you prefer a clean install via our `.iso` file on custom VMs or bare metal:

* **Bare Metal (Real PC):** Flash the ISO to a USB drive (using Rufus or Ventoy) and boot. The installation will run smoothly.
* **VirtualBox ISO Notice (Known Issue):** If you install the `.iso` inside VirtualBox and experience a `GRUB installation failed` error at the very end, this is caused by VirtualBox's NVRAM restrictions. 
  * **How to fix it:** In the GRUB installation step inside the installer, simply check the box that says **"Force extra removable"** (or *no-nvram*). Alternatively, create and run the VM in classic **Legacy/BIOS** mode instead of UEFI.

---

## 🔧 Core System Snippets (Reference & Backups)

### 1. Unified Delayed Autostart Script (`~/start_rechter_conky.sh`)
```bash
#!/bin/bash
# Warte kurz, bis der Desktop groß gezogen ist (Verhindert Zentrierungsfehler)
sleep 6

# Lösche die fehlerhaften Reste aus dem Anmeldefenster
sudo killall -9 conky 2>/dev/null
sleep 1

# Tor sicher und im Hintergrund direkt starten mit dem echten Pfad
sudo /usr/local/bin/tor --RunAsDaemon 1 &
sleep 2

# Phase 1: Sicherheits-Audit & Conky starten
conky -c ~/.conkyrc &
```
---

## ⚖️ Disclaimer of Liability / Haftungsausschluss

### English Version
This software is provided "as is" and any express or implied warranties, including, but not limited to, the implied warranties of merchantability and fitness for a particular purpose are disclaimed. 

In no event shall the author or contributors be liable for any direct, indirect, incidental, special, exemplary, or consequential damages (including, but not limited to, loss of use, data, or profits; or business interruption) however caused and on any theory of liability, whether in contract, strict liability, or tort (including negligence or otherwise) arising in any way out of the use of this software, even if advised of the possibility of such damage.

**Important Operational Notice:** Anonymous networks and routing software are constantly under analysis. This gateway provides strong local hardening, but absolute anonymity can never be guaranteed by software alone. Your operational security (OPSEC) depends entirely on your behavior and workstation configuration.

---

### Deutsche Version
Diese Software wird "wie besehen" (as is) zur Verfügung gestellt. Jegliche ausdrückliche oder implizite Gewährleistung, einschließlich, aber nicht beschränkt auf die implizite Gewährleistung der Marktgängigkeit und Eignung für einen bestimmten Zweck, wird ausgeschlossen.

In keinem Fall haften der Autor oder die Mitwirkenden für direkte, indirekte, zufällige, besondere, exemplarische oder Folgeschäden (einschließlich, aber nicht beschränkt auf die Beschaffung von Ersatzwaren oder -dienstleistungen; Nutzungsausfall, Datenverlust oder entgangenen Gewinn; oder Betriebsunterbrechung), unabhängig davon, wie sie verursacht wurden und auf welcher Haftungstheorie sie beruhen, sei es aus Vertrag, Gefährdungshaftung oder unerlaubter Handlung (einschließlich Fahrlässigkeit), die in irgendeiner Weise aus der Nutzung dieser Software entstehen, selbst wenn auf die Möglichkeit solcher Schäden hingewiesen wurde.

**Wichtiger Betriebshinweis:** Anonyme Netzwerke und Routing-Software stehen unter ständiger Analyse. Dieses Gateway bietet eine extrem starke lokale Härtung, aber absolute Anonymität kann niemals allein durch Software garantiert werden. Deine operative Sicherheit (OPSEC) hängt vollständig von deinem Verhalten und der Konfiguration deiner angeschlossenen Workstation ab.
