#!/bin/bash

# Check if an argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <last-octet>"
    exit 1
fi

# Set the IP address based on the argument
IP="192.168.2.$1/24"

# Delete the IP address from wlan0
echo "Deleting IP address $IP from wlan0..."
sudo ip addr del $IP dev wlan0

# Display wlan0 info after deletion
echo "Displaying wlan0 info..."
iw dev wlan0 info
