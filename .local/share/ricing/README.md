# Laibarch Installation Scripts

Complete automated Arch Linux installation with DWL Wayland compositor, LUKS encryption, and iwd networking.

## Installation Workflow

### Step 1: Create Repository ISO

```bash
bash create-repo-iso.sh
```

Creates `laibarch-repo.iso` containing the entire repository.

### Step 2: Phase 1 - Base Installation (from Arch Live ISO)

Boot from official Arch ISO, attach `laibarch-repo.iso` as second CD-ROM (or USB), then:

```bash
# Mount repository
mkdir /mnt/repo
mount /dev/sr0 /mnt/repo  # or sr1 (check with lsblk), or /dev/sdX for USB

# Run installation script
bash /mnt/repo/.local/share/ricing/laibarch-install.sh
```

**The script auto-detects you're on live ISO and runs Phase 1:**
- Sets up WiFi if needed (using iwctl)
- Auto-detects disk (VM/NVMe/SATA)
- Partitions disk (1GB EFI boot + encrypted root)
- Sets up LUKS encryption
- Installs base system with iwd, NetworkManager, cryptsetup
- Configures NetworkManager to use iwd backend
- Configures systemd-boot bootloader
- Prompts for timezone, locale, hostname, root password

### Step 3: Phase 2 - Post-Installation (after first boot)

Reboot, unlock disk encryption, login as root, then:

```bash
# Mount repository again
mount /dev/sr0 /mnt/repo  # or sr1, check with lsblk

# Run SAME script - it detects Phase 2
bash /mnt/repo/.local/share/ricing/laibarch-install.sh
```

**The script auto-detects you're on installed system and runs Phase 2:**
- Creates user account with sudo privileges
- Copies repository to user's home directory
- Configures pacman (keyring, parallel downloads)
- Installs all packages and builds DWL/slstatus

### Step 4: Complete

Reboot and DWL starts automatically.

---

## File Structure

```
.local/share/ricing/
├── laibarch-install.sh          # Main: Post-installation (run after boot)
├── create-repo-iso.sh            # Helper: Build repository ISO
├── programs.txt                  # Package list for pacman
├── dwl-status-click.sh           # Status bar click handler
├── scripts/
│   ├── encrypted-arch-install.sh # Main: Base installation (from live ISO)
│   ├── chroot-configure.sh       # System configuration (run in chroot)
│   ├── bootstrap.sh              # Build DWL/slstatus, install packages
│   ├── programs-scripts.sh       # Install programs from source
│   └── configure-pacman.sh       # Initialize pacman keyring
└── README.md                     # This file
```

---

## Individual Scripts

### `scripts/encrypted-arch-install.sh`

**Run from**: Arch Live ISO (before installation)

Base system installation with LUKS encryption, partitioning, calls chroot-configure.sh.

### `scripts/chroot-configure.sh`

**Run by**: encrypted-arch-install.sh (inside chroot)

Configures timezone, locale, hostname, root password, sudoers, mkinitcpio, NetworkManager→iwd, systemd-boot.

### `laibarch-install.sh`

**Run from**: First boot as root (after encrypted-arch-install.sh)

User creation, package installation, DWL build.

### `scripts/bootstrap.sh`

**Run by**: laibarch-install.sh (automatically)

Builds DWL/slstatus from source, installs all packages from programs.txt, enables system services.

### `scripts/programs-scripts.sh`

**Run by**: laibarch-install.sh (automatically)

Downloads and builds additional software from source (neovim, brave, etc.).

### `scripts/configure-pacman.sh`

**Run by**: laibarch-install.sh (automatically)

Initializes pacman keyring, enables parallel downloads.

---

## Installed Packages

**System** (from programs.txt):
- Terminals: alacritty, foot
- Shell tools: bat, fd, ripgrep, htop, tmux, stow
- Development: git, github-cli, rust, nodejs, npm, cmake, base-devel
- Wayland: wlroots, wayland-protocols, wl-clipboard, cliphist, wmenu, swww
- X11 (temporary): libx11, libxft (required for slstatus - will migrate to dwlb)
- Utilities: mako, grim, slurp, gammastep, geoclue
- Applications: mpv, mupdf, zathura, yazi, calcurse, obsidian, syncthing
- **iwd**: Network backend (explicitly enabled)

**From source** (programs-scripts.sh):
- neovim (v0.10.4)
- transmission + tremc
- brave-browser
- rate-mirrors
- workstyle

**Services enabled**:
- System: NetworkManager, systemd-resolved, iwd, reflector, geoclue, fstrim.timer
- User: pipewire, pipewire-pulse, wireplumber, syncthing

---

## VM vs Physical Hardware

### For VMs (libvirt/QEMU)

**ISO attachment** (recommended):
```xml
<disk type="file" device="cdrom">
  <source file="/path/to/laibarch-repo.iso"/>
  <target dev="sr0" bus="sata"/>
  <readonly/>
</disk>
```

Device naming: `/dev/vda` (auto-detected)

### For Physical Hardware

**USB preparation**:
```bash
# Option 1: Copy repository to USB
cp -r /path/to/laibarch /media/usb/

# Option 2: Burn ISO to CD/DVD
```

Device naming: `/dev/nvme0n1` (NVMe) or `/dev/sda` (SATA) - auto-detected

---

## Notes

- **LUKS encryption**: Password required on every boot (set during Phase 1)
- **Auto-login**: Not included (add in private configurations if desired)
- **iwd backend**: Configured during base installation; NetworkManager uses iwd from first boot
- **WiFi setup**: Phase 1 handles WiFi connection for live ISO; your credentials persist after install
- **Device detection**: Scripts auto-detect VM/NVMe/SATA disks
- **Patched sources**: DWL/slstatus at `~/.local/src/`
- **Repository copy**: Entire repo copied to user's home during Phase 2
- **External programs**: Cloned to `~/source/repos/`

---

## Security

- All scripts prompt for confirmation before destructive operations
- No hardcoded passwords or sensitive data
- Timezone/hostname prompted during installation
- LUKS encryption with user-chosen strong password
- Auto-login intentionally excluded
- Designed for safe public sharing
