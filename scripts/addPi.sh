#!/bin/bash

# Check if an argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <last-octet>"
    exit 1
fi

# Set the IP address based on the argument
IP="192.168.2.$1/24"

# Stop and disable NetworkManager
echo "Stopping and disabling NetworkManager..."
sudo systemctl stop NetworkManager
sudo systemctl disable NetworkManager

# Bring down and up the wlan0 interface
echo "Bringing down wlan0..."
sudo ip link set wlan0 down
echo "Bringing up wlan0..."
sudo ip link set wlan0 up

# Set wlan0 to IBSS mode
echo "Setting wlan0 to IBSS mode..."
sudo iw wlan0 set type ibss

# Join the PiAdHocNet network
echo "Joining PiAdHocNet on channel 2412..."
sudo iw wlan0 ibss join PiAdHocNet 2412

# Assign the IP address to wlan0
echo "Assigning IP address $IP to wlan0..."
sudo ip addr add $IP dev wlan0

# Bring wlan0 back up
echo "Bringing wlan0 up..."
sudo ip link set wlan0 up

# Display wlan0 info
echo "Displaying wlan0 info..."
iw dev wlan0 info
