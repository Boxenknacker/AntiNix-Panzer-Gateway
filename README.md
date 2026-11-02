# 🛡️ AntiNix-Panzer-Gateway — Version Ironclad 1.11.26
<img width="1598" height="797" alt="unter-last-mit-workstation" src="https://github.com/user-attachments/assets/49e570ec-a7c9-4ef8-ae05-6dcd4fef0ab6" />
An ultra-lightweight, systemd-free, hardened **Tor Gateway** built on top of the rock-solid antiX Linux (Debian base). It acts as an impenetrable digital armor, isolating and routing all network traffic from any connected Workstation securely through the Tor network. 

Inspired by Whonix, but engineered without systemd overhead to be faster, more secure, and extremely resource-efficient.

---

## ⚙️ Technical Specifications & System Architecture

* **Kernel:** 1 Monolithic, hardened Linux Kernel
* **RAM:** 512 MB minimum (Runs perfectly), 1024 MB recommended
* **Storage:** 10 GB Virtual Disk Space
* **CPU:** 1 Core allocation is highly sufficient
* **Architecture:** 64-Bit (Intel/AMD)
* **Virtualization:** Universally compatible with VirtualBox, VMware, KVM, and Bare Metal.
* **Security Isolation:** VirtualBox Guest Additions are **intentionally omitted** to eliminate host-leak risks and prevent VM-escape exploits.

---

## 🔒 Key Features (Ironclad Specifications)

### 1. Network & Leak Protection
* **Firewall Autostart (nftables):** Blocks all unencrypted traffic from the very first second of the boot process. Zero time-window for data leaks (Absolute Leak-Protection).
* **WireGuard with Kill-Switch (Pre-installed & Optional):** Allows you to optionally chain a VPN before or after Tor. The integrated Kill-Switch instantly drops all traffic if the VPN disconnects.
* **Fixed Network Interface Names:** Interfaces are hardcoded as `eth0` (External Internet) and `eth1` (Internal Workstation LAN). No dynamic naming confusion, making the firewall 100% predictable and leak-proof.
* **Tor Autostart with Nyx Monitoring:** The Tor network initializes automatically on boot. Real-time traffic, relays, and connections can be monitored live via the integrated **Nyx** terminal interface.
* **UTC System Time:** Forces Coordinated Universal Time (UTC) to eliminate time-zone fingerprinting by malicious websites.

### 2. Kernel & OS Hardening
* **Kernel Hardening:** Restrictive sysctl and boot-time configurations protect against common exploits and local root vulnerabilities.
* **BPF Kernel Filter:** Utilizes highly efficient Berkeley Packet Filters directly in kernel-space to instantly drop malicious or manipulated network packets.
* **RAM Protection:** Prevents unauthorized memory dumping and scraping of sensitive cryptographic data during runtime.
* **Systemd-Free Architecture:** Powered by SysVinit/Runit. Eliminating the bloated systemd surface area ensures maximum control and a minimal attack vector.
* **First-Boot SSH Key Generation:** Contains no pre-baked cryptographic keys. Unique SSH host keys are generated securely on the user's first boot, preventing supply-chain interception.

### 3. Performance & User Experience
* **Ultra-Lightweight Idle:** Consumes only **200 to 250 MB RAM** at idle. Ideal for older hardware and resource-constrained host machines.
* **Intelligent GUI (IceWM Desktop):** Hardcore security doesn't mean terminal-only torture. Includes a highly optimized, lightweight graphical user interface.
* **Graphical Control Center:** An in-house control dashboard allows users to start, stop, or reload the Tor Gateway with a single click while visually checking the system's security status.
* **Live Hardware Monitors:** Real-time desktop widgets display exact network interface activity, RAM consumption, and CPU load at a glance.
* **Universal Workstation Compatibility:** Open to any client OS. Connect a Whonix-Workstation, Debian, Tails, or even a Windows VM to `eth1` and route it instantly and safely.

---
## 💾 Downloads & Integrity Verification

To ensure your download has not been corrupted or tampered with, always verify the checksum after downloading.

| File Name | Format | Source | Checksum & Hash Value |
| :--- | :--- | :--- | :--- |
| `antinix-panzer-gateway-ironclad-1.11.26.iso` | Live ISO | [Download from MEGA](https://mega.nz/file/qPxTkIIB#nkin_Iv7DZqbNWN9mnQxvGYzvVExbI-FsCy0eIDuXN0) | **MD5:** `4ba50944b9f9fc5bee826a5dbc36451e` / [View File](./antinix-panzer-gateway-ironclad-1.11.26.iso.md5) |


### How to verify on your host system:

#### For the Installation Image (.iso):
* **Linux:** `md5sum antinix-panzer-gateway-ironclad-1.11.26.iso`
* **Windows (PowerShell):** `Get-FileHash .\antinix-panzer-gateway-ironclad-1.11.26.iso -Algorithm MD5`

---

## 🚀 Quick Start & Deployment (.ova)

To avoid manual partitioning and bypass virtual environment NVRAM constraints, follow these steps to set up the Live ISO:

1. Download the `.iso` file from the source link and verify the MD5 hash.
2. In VirtualBox, create a new VM (Type: Linux / Debian 64-bit) and mount the `.iso` file as an optical drive under **Settings** ➔ **Storage**.
3. Ensure your target Workstation VM's network adapter is set to **Internal Network** linked to the Gateway's `eth1` interface.

### 🔑 Default Credentials
* **Username:** `user`
* **Password:** `changeme`
* *⚠️ NOTE: For security reasons, you must change this default password immediately upon your first login (`passwd` command).*

---

## 🛠️ ISO Installation & Troubleshooting Notice

If you prefer a clean install via our `.iso` file on custom VMs or bare metal:

* **Bare Metal (Real PC):** Flash the ISO to a USB drive (using Rufus or Ventoy) and boot. The installation will run smoothly.
* **VirtualBox ISO Notice (Known Issue):** If you install the `.iso` inside VirtualBox and experience a `GRUB installation failed` error at the very end, this is caused by VirtualBox's NVRAM restrictions. 
  * **How to fix it:** In the GRUB installation step inside the installer, simply check the box that says **"Force extra removable"** (or *no-nvram*). Alternatively, create and run the VM in classic **Legacy/BIOS** mode instead of UEFI.

---

## ⚖️ Legal Disclaimer & Terms of Use

### 1. Disclaimer of Liability (Haftungsausschluss)
This software is provided "as is" and "with all faults," without any express or implied warranties of any kind. In no event shall the developers or contributors be liable for any direct, indirect, incidental, special, exemplary, or consequential damages (including, but not limited to, loss of use, data, or profits; or business interruption) however caused and on any theory of liability, whether in contract, strict liability, or tort (including negligence or otherwise) arising in any way out of the use of this software, even if advised of the possibility of such damage.

### 2. Lawful Use Only
The developers do not condone, encourage, or support any illegal activities conducted through this software. It is the sole responsibility of the user to comply with all applicable local, national, and international laws and regulations regarding online privacy, data routing, encryption, and the use of the Tor network. By using this software, you agree not to use it for any unlawful purposes.

### 3. Trademark Notice
This project is an independent open-source derivative and is **not affiliated with, endorsed by, or associated with** The Tor Project, antiX Linux, the Debian Project, or Oracle VM. 
* "Tor" and the "Tor Onion Logo" are registered trademarks of The Tor Project, Inc.
* "antiX" is a trademark of the antiX Linux project.
* "Debian" is a registered trademark of Software in the Public Interest, Inc.
* "VirtualBox" is a registered trademark of Oracle Corporation.
