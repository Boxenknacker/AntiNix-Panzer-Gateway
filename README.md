# # 🛡️ AntiNix-Panzer-Gateway — Version Ironclad 1.11.26
> **"Lightweight outside. Ironclad inside."**
<img width="1598" height="797" alt="unter-last-mit-workstation" src="https://github.com/user-attachments/assets/49e570ec-a7c9-4ef8-ae05-6dcd4fef0ab6" />

An ultra-lightweight, systemd-free, hardened **Tor Gateway** built on antiX Linux (Debian base). It acts as digital armor, isolating and routing all traffic from connected workstations securely through Tor. Inspired by Whonix, but built without systemd for better performance and resource efficiency.

---

## ⚙️ Technical Specifications & System Architecture

* **Kernel:** Monolithic, hardened Linux Kernel
* **RAM:** 512 MB minimum (1024 MB recommended)
* **Storage:** 10 GB Virtual Disk Space
* **CPU:** 1 Core allocation
* **Architecture:** 64-Bit (Intel/AMD)
* **Virtualization:** Compatible with VirtualBox, VMware, KVM, and Bare Metal.
* **Security Isolation:** VirtualBox Guest Additions are **omitted** to eliminate host-leak risks and prevent VM-escape exploits.

---

## 🔒 Key Features (Ironclad Specifications)

### 1. Network & Leak Protection
* **Firewall Autostart (`nftables`):** Blocks all unencrypted traffic immediately from boot.
* **WireGuard with Kill-Switch:** Optional VPN chaining before or after Tor, with an integrated kill-switch.
* **Fixed Network Interface Names:** Hardcoded as `eth0` (External Internet) and `eth1` (Internal Workstation LAN) for predictability.
* **Tor Autostart with Nyx:** Automatic initialization with live monitoring via **Nyx**.
* **UTC System Time:** Enforces Coordinated Universal Time to prevent time-zone fingerprinting.

### 2. Kernel & OS Hardening
* **Kernel Hardening:** Restrictive `sysctl` and boot configurations against exploits.
* **BPF Kernel Filter:** Kernel-space Berkeley Packet Filters to drop malicious packets.
* **RAM Protection:** Prevents unauthorized memory dumping of sensitive data.
* **Systemd-Free Architecture:** Powered by SysVinit/Runit for a minimal attack surface.
* **First-Boot SSH Key Generation:** Unique SSH host keys are generated securely on the first boot.

### 3. Performance & User Experience
* **Ultra-Lightweight Idle:** Consumes only 200–250 MB RAM.
* **IceWM Desktop:** Lightweight graphical user interface with an in-house control dashboard.
* **Live Hardware Monitors:** Real-time desktop widgets for network, RAM, and CPU usage.
* **Universal Workstation Compatibility:** Connect any standard Debian, Windows, or custom VM to `eth1`.

---

## 💾 Downloads & Integrity Verification

| File Name | Format | Source | Checksum & Hash Value |
| :--- | :--- | :--- | :--- |
| `antinix-panzer-gateway-ironclad-1.11.26.iso` | Live ISO | [Download from MEGA](https://mega.nz/file/vDxzhaxK#8OBNOLsM8lz4jWTyG-CuJ97UkiS8B2l_BzF_uH3okrM) | **MD5:** `d8dcd1943b1b00fc4decdcb65e35b159` |

### Verification Commands:
* **Linux:** `md5sum antinix-panzer-gateway-ironclad-1.11.26.iso`
* **Windows (PowerShell):** `Get-FileHash .\antinix-panzer-gateway-ironclad-1.11.26.iso -Algorithm MD5`

---

## 🚀 Quick Start & Deployment (.iso)

1. Download and verify the `.iso` file.
2. In VirtualBox, create a Linux/Debian 64-bit VM and mount the `.iso` under **Settings** ➔ **Storage**.
3. Set your target Workstation VM's network adapter to **Internal Network** linked to `eth1`.

### 🔑 Default Credentials
* **Username:** `user`
* **Password:** `changeme` (*Change immediately via `passwd`*).

---

## 🛠️ ISO Installation & Troubleshooting Notice

* **Bare Metal:** Flash ISO to a USB drive via Rufus or Ventoy.
* **VirtualBox NVRAM Issue:** If a `GRUB installation failed` error occurs, check **"Force extra removable"** (`no-nvram`) during the installer's GRUB step, or use classic Legacy/BIOS mode.

---

## ❓ Frequently Asked Questions (FAQ)

### Q: Why is there no web browser installed on the Panzer-Gateway?
**A:** By design and strict security policy. Following the industry-standard Whonix architecture, a routing gateway must never run a web browser. Opening a browser on the gateway breaches the isolation boundary; a browser exploit could instantly reveal the host's real external WAN IP address (deanonymization). All web traffic must be isolated to the connected Workstation.

---

## ⚖️ Legal Disclaimer & Terms of Use

1. **Disclaimer of Liability:** Provided "as is" without warranties of any kind. Developers are not liable for any damages arising from its use.
2. **Lawful Use Only:** Users must comply with all local and international laws regarding privacy and the Tor network.
3. **Trademark Notice:** Independent open-source derivative not affiliated with The Tor Project, antiX Linux, Debian, or Oracle.
