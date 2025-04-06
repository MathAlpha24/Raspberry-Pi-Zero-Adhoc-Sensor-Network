#!/bin/bash

# Define the network range for the Ad-Hoc network
network="192.168.2"

# Get the current IP address of the system
current_ip=$(hostname -I | awk '{print $1}')

# Display the current IP address
echo "Current IP address: $current_ip"

# Use arp command to list devices connected to the network
# Filter out devices on the same subnet (you can modify the network part as needed)
connected_devices=$(arp -n | grep "$network" | awk '{print $1}')

# Add the current device IP to the list of connected devices
connected_devices="$current_ip $connected_devices"

# Count the number of connected devices, including the current device
device_count=$(echo "$connected_devices" | wc -w)

# Display the number of connected devices
echo "Number of devices connected to the Ad-Hoc network: $device_count"

# Display the exact IP addresses
if [ $device_count -gt 0 ]; then
    echo "IP Addresses of connected devices:"
    echo "$connected_devices"
else
    echo "No devices found on the Ad-Hoc network."
fi
