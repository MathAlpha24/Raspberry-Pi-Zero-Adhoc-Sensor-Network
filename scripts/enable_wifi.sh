#!/bin/bash

# FORMAT BELOW:
# ./enable_wifi.sh "YourSSID" "YourPassword"

SSID="$1"
PASSWORD="$2"

if [ -z "$SSID" ] || [ -z "$PASSWORD" ]; then
    echo "Usage: $0 <SSID> <Password>"
    exit 1
fi

echo "Switching wlan0 to managed mode..."
sudo ip link set wlan0 down
sudo iw wlan0 set type managed
sudo ip link set wlan0 up

echo " Restarting NetworkManager..."
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager

echo "Connecting to SSID: $SSID"
nmcli device wifi connect "$SSID" password "$PASSWORD"

echo " Checking connection..."
sleep 2
iw dev wlan0 link
