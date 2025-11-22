# Laibarch

~Life~ Arch is Life!

My Arch Linux rice. DWL window manager, LUKS encryption, automated installation.

## Installation

### 1. Create ISO
```bash
bash .local/share/ricing/create-repo-iso.sh
```

### 2. Run Installation (from Arch Live ISO)
```bash
mount /dev/sr0 /mnt/repo  # or sr1, check with lsblk
bash /mnt/repo/.local/share/ricing/laibarch-install.sh
```

Phase 1: Partitioning, LUKS encryption, base system, bootloader.

### 3. After Reboot (login as root)
```bash
mount /dev/sr0 /mnt/repo
bash /mnt/repo/.local/share/ricing/laibarch-install.sh
```

Phase 2: User creation, package installation, DWL build.

### 4. Done

Reboot and DWL starts.

## What's In Here

- **Full disk encryption** with LUKS
- **DWL** with custom patches
- **iwd** network backend
- **Wayland-native** stack
- **Automated** from bare metal to working system

Tested on VMs and hardware.

## Documentation

For detailed documentation see `.local/share/ricing/README.md`
