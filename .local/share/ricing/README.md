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
# Mount repository (use /repo, NOT under /mnt - it gets unmounted during install)
mkdir /repo
mount /dev/sr0 /repo  # or sr1 (check with lsblk), or /dev/sdX for USB

# Run installation script
bash /repo/.local/share/ricing/laibarch-install.sh
```

**The script auto-detects you're on live ISO and runs Phase 1:**

- Sets up WiFi if needed (using iwctl)
- Auto-detects disk (VM/NVMe/SATA)
- Partitions disk (1GB EFI boot + encrypted root)
- Sets up LUKS encryption
- Installs base system with iwd, NetworkManager, cryptsetup
- Configures NetworkManager to use iwd backend (NetworkManager->iwd)
- Configures systemd-boot bootloader
- Prompts for timezone, locale, hostname, root password

### Step 3: Phase 2 - Post-Installation (after first boot)

Reboot, unlock disk encryption, login as root, then:

```bash
# Mount repository again
mkdir /repo
mount /dev/sr0 /repo  # or sr1, check with lsblk

# Run SAME script - it detects Phase 2
bash /repo/.local/share/ricing/laibarch-install.sh
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

Configures timezone, locale, hostname, root password, sudoers, mkinitcpio, NetworkManager->iwd, systemd-boot.

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
- Shell tools: zsh, zsh-completions, bat, fd, ripgrep, htop, tmux, stow
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

## Hardware-Specific Features

### Brightness Control

Works on both laptops and desktops via universal script (`~/.local/bin/brightness.sh`):

**Laptops:**
- Uses `brightnessctl` for built-in backlight
- Detects `class 'backlight'` devices

**Desktops:**
- Uses `ddcutil` for external monitors (DDC/CI protocol)
- Requires `i2c-dev` kernel module (auto-loaded)
- User must be in `i2c` group (auto-configured)

Keybindings: `MODKEY+Shift+-` / `MODKEY+Shift+=`

### Temperature Monitoring

Status bar shows highest temperature across all sensors:

**Detection priority:**
1. `sensors` command (lm_sensors) - reads all hwmon devices
2. Falls back to `/sys/class/thermal/thermal_zone0/temp` (laptops)
3. Shows `n/a` if no sensors available

**Desktop systems:**
- k10temp (AMD Ryzen CPU)
- amdgpu (AMD GPU edge temp)
- nvme (NVMe SSD)

**Laptop systems:**
- ACPI thermal zones

Click widget shows detailed per-component temperatures.

### Systemd User Services

Battery and temperature monitors run as systemd user timers:

**Battery Monitor** (`battery-monitor.timer`):
- Runs every 2 minutes
- Sends notifications at 20%, 10%, 5% levels
- Only active on systems with battery

**Temperature Monitor** (`temp-monitor.timer`):
- Runs every 1 minute
- Sends notification if any sensor exceeds 80°C
- Works on desktops and laptops

Services located at: `~/.config/systemd/user/`

## Notes

- **LUKS encryption**: Password required on every boot (set during Phase 1)
- **Auto-login**: Not included (add separately if desired)
- **iwd backend**: Configured during base installation; NetworkManager uses iwd from first boot
- **WiFi setup**: Phase 1 handles WiFi connection for live ISO; your credentials persist after install
- **Device detection**: Scripts auto-detect VM/NVMe/SATA disks
- **Patched sources**: DWL/slstatus at `~/.local/src/`
- **Repository structure**: Entire `$HOME` is a git repository with selective `.gitignore`
- **Repository copy**: Entire repo copied to user's home during Phase 2
- **External programs**: Cloned to `~/source/repos/`

---

## Terminal Stack

The terminal stack follows the standard architecture: `Kernel -> DWL -> Alacritty -> Tmux -> Shell`

### Components

**Alacritty** (`~/.config/alacritty/alacritty.toml`)
- Terminal emulator (creates PTY, renders text)
- Minimal config: font size 8.5, 85% opacity, clipboard bindings

**Tmux** (`~/.config/tmux/tmux.conf`)
- Terminal multiplexer (sessions, panes)
- Prefix: `Ctrl+e` (default `Ctrl+b` unbound)
- Vim-style pane navigation: `hjkl`
- Vi mode for copy: `set -g mode-keys vi`
- Plugins via TPM: resurrect, continuum, sessionx, floax, catppuccin theme
- Auto-restore sessions on start

**Shell** (Zsh, with Bash available)
- Zsh is the default login shell (set via `chsh` during installation)
- Auto-starts tmux when in terminal emulator (checks for `/dev/pts/*`)
- Vim mode with cursor shape change (block for normal, beam for insert)
- Git branch + status in prompt (`*` unstaged, `+` staged)
- Plugins: zsh-autosuggestions, zsh-syntax-highlighting

**Bash/Zsh Relationship:**
- Zsh does NOT read `.bashrc` or `.bash_profile` - they're separate shells
- `.bashrc` kept for when bash is needed (scripts, emergency)
- Aliases duplicated in both (may diverge as zsh-specific features added)

### Configuration Files

| Component | Config Location | Tracked in git |
|-----------|-----------------|----------------|
| Alacritty | `~/.config/alacritty/alacritty.toml` | Yes |
| Tmux | `~/.config/tmux/tmux.conf` | Yes |
| Zsh | `~/.zshenv`, `~/.config/zsh/.zshrc` | Yes |
| Zsh plugins | `~/.local/share/zsh/plugins/` | Yes |
| Bash | `~/.bashrc` | Yes |

### Behavior Flow

1. Open alacritty -> spawns zsh
2. Zsh checks if in PTY (`/dev/pts/*`) and not already in tmux
3. If true, `exec tmux` replaces zsh with tmux
4. Tmux spawns new zsh instances in each pane
5. Each pane gets its own PTY under `/dev/pts/`

### Observations

**Working well:**
- Vim keybindings in tmux
- Session persistence (resurrect + continuum)
- Clean separation of concerns

**Potential improvements:**
- Tmux uses `xclip` but system is Wayland -> should use `wl-copy`
- Many tmux plugins - evaluate which are actually used
- Zsh will replace bash for better completion and vim mode in shell itself

---

## Security

- All scripts prompt for confirmation before destructive operations
- No hardcoded passwords or sensitive data
- Timezone/hostname prompted during installation
- LUKS encryption with user-chosen strong password
- Auto-login intentionally excluded
- Designed for safe public sharing
