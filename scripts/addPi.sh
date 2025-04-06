#!/bin/bash

# Check if argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <number>"
  echo "Example: $0 5 will set IP 192.168.4.5/24"
  exit 1
fi

# Variables
ESSID="PiAdHoc"           # ESSID for the ad hoc network
CHANNEL=1                  # Channel for the ad hoc network
IP_ADDRESS="192.168.4.$1"  # IP address based on the provided argument

# Disable wlan0 interface
sudo ip link set wlan0 down

# Set wlan0 to ad-hoc mode
sudo iwconfig wlan0 mode ad-hoc

# Set ESSID and channel
sudo iwconfig wlan0 essid "$ESSID"
sudo iwconfig wlan0 channel "$CHANNEL"

# Assign IP address to wlan0
sudo ip addr add "$IP_ADDRESS"/24 dev wlan0

# Enable wlan0 interface
sudo ip link set wlan0 up

# Display wlan0 information
iw dev wlan0 info
