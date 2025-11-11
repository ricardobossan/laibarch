# Rice Configuration

Automated setup for DWL Wayland compositor with slstatus bar on Arch Linux.

## Prerequisites

- Basic Arch Linux installation completed
- System partitioned, formatted, and bootloader installed
- System booted into the installation

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
- Development: `git`, `github-cli`, `rust`, `nodejs`, `npm`
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
run-section2.sh (as root):
  ├─> Configure root password (interactive)
  ├─> Configure sudo/wheel group
  ├─> Create user (interactive)
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
.
├── run-section1.sh           # Master script: Standard setup
├── run-section2.sh           # Master script: Complete fresh install
├── bootstrap.sh              # Build DWL/slstatus, install packages
├── programs-scripts.sh       # Build programs from source
├── configure-pacman.sh       # Initialize pacman keyring
├── configure-network.sh      # NetworkManager + iwd setup
├── programs.txt              # Pacman package list
└── dwl-status-click.sh       # Status bar click handler
```

## Requirements

- DWL and slstatus source must be at `~/.local/src/dwl` and `~/.local/src/slstatus`
- For `programs-scripts.sh`: repositories will be cloned to `~/source/repos/`
- For Section 2: Run from pendrive with script directory accessible

## Notes

- All master scripts use relative paths from their location (pendrive-safe)
- `run-section2.sh` must be run as root
- `run-section1.sh` can be run as regular user
- WiFi credentials are only used temporarily for reconnection (not stored)
