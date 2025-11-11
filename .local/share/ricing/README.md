# Rice Configuration

Automated setup for DWL Wayland compositor with slstatus bar on Arch Linux.

## Prerequisites

- Basic Arch Linux installation completed
- System partitioned, formatted, and bootloader installed
- System booted into the installation
- This repository cloned or copied to the user's home directory
  - Contains patched dwl and slstatus sources at `~/.local/src/`

## Section 1: Standard Setup

For systems where **user**, **internet**, and **pacman** are already configured.

### Quick Start

```bash
bash run-section1.sh
```

### What It Does

1. **`bootstrap.sh`** - Builds DWL/slstatus, installs system packages, enables services
2. **`programs-scripts.sh`** - Installs additional software from source

### Installed Packages

**System packages** (from `programs.txt`):
- Terminal: `alacritty`, `foot`
- Shell: `stow`, `bat`, `fd`, `ripgrep`, `htop`, `tmux`
- Development: `git`, `github-cli`, `rust`, `nodejs`, `npm`, `cmake`, `base-devel`, `pkg-config`
- Wayland: `wlroots`, `wayland-protocols`, `wl-clipboard`, `cliphist`, `wmenu`, `swww`
- Utilities: `mako`, `grim`, `slurp`, `gammastep`, `geoclue`
- Applications: `mpv`, `mupdf`, `zathura`, `yazi`, `calcurse`, `obsidian`, `syncthing`

**From source**:
- neovim (v0.10.4)
- transmission + tremc
- brave-browser
- rate-mirrors
- workstyle

**Services enabled**:
- System: `NetworkManager`, `systemd-resolved`, `reflector`, `geoclue`, `fstrim.timer`
- User: `pipewire`, `pipewire-pulse`, `wireplumber`, `syncthing`

---

## Section 2: Complete Fresh Install

For fresh Arch installations requiring full setup from a **pendrive** (no internet configured yet).

### Quick Start

```bash
# Run as root from pendrive
sudo bash run-section2.sh
```

### What It Does

The script will prompt you interactively for:
1. Root password
2. New username
3. New user password
4. WiFi SSID
5. WiFi password

Then automatically:
1. Configures sudo for wheel group
2. Creates new user with sudo privileges
3. Initializes pacman keyring and enables parallel downloads
4. Runs Section 1 installation (downloads and installs all packages)
5. Switches NetworkManager to use iwd backend
6. Reconnects to WiFi automatically

### Execution Flow

```
run-section2.sh (as root from pendrive):
  ├─> Configure root password (interactive)
  ├─> Configure sudo/wheel group
  ├─> Create user (interactive)
  ├─> Copy repository from pendrive to user home directory
  ├─> configure-pacman.sh (initialize keyring, enable parallel downloads)
  ├─> Get WiFi credentials (interactive, for reconnection)
  ├─> run-section1.sh (as new user)
  │     ├─> bootstrap.sh (build dwl/slstatus, install packages, enable services)
  │     └─> programs-scripts.sh (install from source)
  ├─> configure-network.sh (switch to iwd backend - disconnects temporarily)
  └─> Reconnect WiFi using saved credentials
```

---

## Individual Scripts

If you need to run specific parts manually:

### `configure-pacman.sh`
```bash
sudo bash configure-pacman.sh
```
Initializes pacman keyring, updates packages, enables parallel downloads.

### `configure-network.sh`
```bash
sudo bash configure-network.sh
```
Switches NetworkManager to use iwd instead of wpa_supplicant.

**Note**: This restarts NetworkManager and temporarily disconnects network. Reconnect with:
```bash
nmcli device wifi connect "SSID" password "PASSWORD"
```

### `bootstrap.sh`
```bash
bash bootstrap.sh
```
Builds and installs DWL/slstatus, installs system packages, enables services.

### `programs-scripts.sh`
```bash
bash programs-scripts.sh
```
Downloads and builds software from source.

---

## Post-Installation

Reboot to start DWL:
```bash
reboot
```

---

## File Structure

```
~ (home directory)
├── .local/
│   ├── src/
│   │   ├── dwl/              # Patched dwl source (part of repo)
│   │   └── slstatus/         # Patched slstatus source (part of repo)
│   └── share/
│       └── ricing/           # This directory
│           ├── run-section1.sh           # Master: Standard setup
│           ├── run-section2.sh           # Master: Complete fresh install
│           ├── bootstrap.sh              # Build DWL/slstatus, install packages
│           ├── programs-scripts.sh       # Build programs from source
│           ├── configure-pacman.sh       # Initialize pacman keyring
│           ├── configure-network.sh      # NetworkManager + iwd setup
│           ├── programs.txt              # Pacman package list
│           └── dwl-status-click.sh       # Status bar click handler
```

## Repository Setup

### For Section 1 (existing system):
```bash
# Clone repo to home directory
cd ~
git clone <repo-url> .
```

### For Section 2 (fresh install from pendrive):
1. Clone/copy this repository to a pendrive
2. Boot fresh Arch install
3. Mount pendrive and navigate to the scripts directory:
   ```bash
   mount /dev/sdX1 /mnt  # Replace sdX1 with your pendrive
   cd /mnt/.local/share/ricing
   sudo bash run-section2.sh
   ```
4. The script will automatically copy the repository to the new user's home

## Notes

- Repo includes patched dwl/slstatus sources at `~/.local/src/`
- All scripts use relative paths (pendrive-safe)
- `run-section2.sh` must be run as root
- `run-section1.sh` runs as regular user
- WiFi credentials used only for reconnection (not stored)
- External programs cloned to `~/source/repos/`
