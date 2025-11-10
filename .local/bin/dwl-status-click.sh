#!/bin/sh
# dwl status bar widget click handler
# Usage: dwl-status-click.sh <widget_name> <button>
# button: 1=left, 2=middle, 3=right

widget="$1"
button="$2"

case "$widget" in
cpu)
  case "$button" in
  1) # Left click - show detailed CPU info
    cpu_info=$(top -bn1 | grep "Cpu(s)" | awk '{print "CPU: " $2 "% user, " $4 "% system, " $8 "% idle"}')
    notify-send "CPU Usage" "$cpu_info"
    ;;
  3) # Right click - open htop
    alacritty -e htop &
    ;;
  esac
  ;;
ram)
  case "$button" in
  1) # Left click - show detailed RAM info
    ram_info=$(free -h | awk '/^Mem:/ {print "Total: " $2 "\nUsed: " $3 " (" $3/$2*100 "%)\nFree: " $4}')
    notify-send "RAM Usage" "$ram_info"
    ;;
  3) # Right click - open htop
    alacritty -e htop &
    ;;
  esac
  ;;
temp)
  case "$button" in
  1) # Left click - show temperature details
    temp=$(sensors 2>/dev/null || cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -1 | awk '{print $1/1000 "°C"}')
    notify-send "Temperature" "System: $temp"
    ;;
  3) # Right click - open sensors
    alacritty -e watch -n1 sensors &
    ;;
  esac
  ;;
network)
  case "$button" in
  1) # Left click - show network details
    net_info=$(nmcli -t -f TYPE,STATE,CONNECTION dev | grep -v '^lo:' | awk -F: '{print $1 ": " $3 " (" $2 ")"}')
    notify-send "Network Status" "$net_info"
    ;;
  3) # Right click - open nmtui
    alacritty -e nmtui &
    ;;
  esac
  ;;
volume)
  case "$button" in
  1) # Left click - show volume details
    vol_info=$(amixer sget Master | grep -o '[0-9]*%' | head -1)
    mute_status=$(amixer sget Master | grep -o '\[on\]\|\[off\]' | head -1)
    notify-send "Volume" "Level: $vol_info\nStatus: $mute_status"
    ;;
  3) # Right click - open pulsemixer or alsamixer
    if command -v pulsemixer >/dev/null 2>&1; then
      alacritty -e pulsemixer &
    else
      alacritty -e alsamixer &
    fi
    ;;
  esac
  ;;
battery)
  case "$button" in
  1) # Left click - show battery details
    bat_info=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 2>/dev/null | grep -E 'state|percentage|time to' || acpi)
    notify-send "Battery Status" "$bat_info"
    ;;
  3) # Right click - open power settings
    # Adjust based on your desktop environment
    if command -v gnome-control-center >/dev/null 2>&1; then
      gnome-control-center power &
    elif command -v xfce4-power-manager-settings >/dev/null 2>&1; then
      xfce4-power-manager-settings &
    else
      notify-send "Power Settings" "No power manager GUI found"
    fi
    ;;
  esac
  ;;
datetime)
  case "$button" in
  1) # Left click - show calendar
    cal_info=$(cal)
    notify-send "Calendar" "$cal_info"
    ;;
  3) # Right click - open calcurse
    if command -v calcurse >/dev/null 2>&1; then
      alacritty -e calcurse -D ${HOME}/Documents/calcurse &
    else
      notify-send "Calendar" "calcurse not installed"
    fi
    ;;
  esac
  ;;
esac
