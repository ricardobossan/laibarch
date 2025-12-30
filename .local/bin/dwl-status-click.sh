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
    temp_info=$(sensors 2>/dev/null | grep -E '^(k10temp|amdgpu|nvme|coretemp)' -A5 | grep -E '(Tctl|edge|Composite|Core|temp1):' | head -5)
    if [ -z "$temp_info" ]; then
      temp_info=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk '{printf "%.0f°C", $1/1000}')
    fi
    notify-send "Temperature" "$temp_info"
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
bluetooth)
  case "$button" in
  1) # Left click - open bluetuith
    bt_power=$(bluetoothctl show 2>/dev/null | grep "Powered:" | awk '{print $2}')
    bt_devices=$(bluetoothctl devices 2>/dev/null | wc -l)
    bt_connected=$(bluetoothctl devices Connected 2>/dev/null)
    if [ -n "$bt_connected" ]; then
      bt_info="Power: $bt_power\nPaired devices: $bt_devices\n\nConnected:\n$bt_connected"
    else
      bt_info="Power: $bt_power\nPaired devices: $bt_devices\n\nNo devices connected"
    fi
    notify-send "Bluetooth Status" "$bt_info"
    ;;
  3) # Right click - show bluetooth info
    if command -v bluetuith >/dev/null 2>&1; then
      alacritty -e bluetuith &
    else
      notify-send "Bluetooth" "bluetuith not installed"
    fi
    ;;
  esac
  ;;
esac
