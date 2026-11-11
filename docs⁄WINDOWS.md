# Running AntiNix-Panzer-Gateway on Windows (VM & Portable Setup)

`AntiNix-Panzer-Gateway` is a hardened, `systemd`-free Linux operating system (required for kernel-level `nftables` Tor enforcement and network isolation). Therefore, there is no native `.exe` installer—instead, you run the Gateway inside a Virtual Machine on Windows or boot it from a portable USB drive.

---

## Option 1: Standard Windows Setup (VirtualBox / VMware)

1. **Install Virtualization Software:**  
   Download and install **Oracle VirtualBox** (free) or **VMware Workstation Player** on your Windows host.
2. **Create the Gateway VM (`AntiNix-Panzer-Gateway`):**
   * **Type:** Linux | **Version:** Debian (64-bit) | **RAM:** `1024 MB` | **Disk:** `8 GB`
   * **Adapter 1 (`eth0` — WAN):** Attached to **NAT** (Internet uplink)
   * **Adapter 2 (`eth1` — Internal Tor Network):** Attached to **Internal Network** — Name: **`antinix-net`**
   * Boot from `AntiNix-Panzer-Gateway-v1.0-amd64.iso` and install to the virtual disk.
3. **Connect Your Client / Workstation VM:**  
   Attach any Linux/BSD client VM to the same **Internal Network (`antinix-net`)** with static IP `10.152.152.50/24`, default gateway `10.152.152.10`, and DNS `10.152.152.10`. All traffic is automatically forced through Tor.

---

## Option 2: Portable Setup on Windows (No Host Installation)

### Method A: VirtualBox Portable on a USB Drive (Run inside Windows)
1. Format a fast USB 3.0+ drive (8 GB or larger) as **exFAT** or **NTFS**.
2. Install **VirtualBox Portable** onto the USB drive.
3. Set VirtualBox's default machine folder to your USB drive and store the `AntiNix-Panzer-Gateway` VM there.
4. Plug the USB drive into any Windows PC and launch the Gateway directly without installing anything on the host.

### Method B: Ventoy Bootable USB Stick (Bare-Metal Live Boot)
1. Install **Ventoy** onto a USB stick (4 GB+).
2. Copy `AntiNix-Panzer-Gateway-v1.0-amd64.iso` onto the USB stick's main partition.
3. Reboot the PC, open the BIOS/UEFI boot menu (`F12` / `F8` / `Esc`), and boot directly into the Gateway.

---

## Windows Security Tips
* **Disable Shared Clipboard & Drag-and-Drop** on the Gateway VM to keep it strictly isolated from the Windows host.
* **Set Promiscuous Mode to `Deny`** on the virtual network adapters (`antinix-net`).
