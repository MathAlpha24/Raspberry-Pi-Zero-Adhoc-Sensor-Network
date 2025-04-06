#!/bin/bash

# Stop and disable wpa_supplicant
sudo systemctl stop wpa_supplicant
sudo systemctl disable wpa_supplicant

# Stop and disable NetworkManager
sudo systemctl stop NetworkManager
sudo systemctl disable NetworkManager

# Bring wlan0 down and up
sudo ip link set wlan0 down
sudo ip link set wlan0 up

# Set wlan0 to IBSS mode
sudo iw wlan0 set type ibss

# Join the PiAdHocNet network on channel 2412
sudo iw wlan0 ibss join PiAdHocNet 2412

# Ensure wlan0 is up
sudo ip link set wlan0 up

