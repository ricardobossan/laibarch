#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mapfile -t packages < <(grep -v '^[[:space:]]*$' "$SCRIPT_DIR/../programs.txt")

sudo pacman -Syu --needed "${packages[@]}"
