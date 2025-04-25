#!/bin/bash

set -e  # Exit on any error

# === 1. Install Required Libraries ===
echo "📦 Installing required dependencies..."

# Update package list and install necessary tools and libraries
sudo apt update
sudo apt install -y python3 python3-venv python3-pip git iw

# Install Python dependencies (Adafruit DHT and others)
echo "Installing Python packages..."
pip3 install --upgrade pip  # Make sure pip is up to date
pip3 install Adafruit_DHT

# === 2. Set Up the Ad-Hoc Network ===
echo "📡 Setting up ad hoc Wi-Fi network..."

# Make sure you have the last octet as the first argument
if [ -z "$1" ]; then
    echo "Usage: $0 <last-octet-of-IP>"
    exit 1
fi

LAST_OCTET=$1
IP="192.168.2.$LAST_OCTET/24"

# Stop NetworkManager and set up the ad-hoc network
echo "Stopping NetworkManager..."
sudo systemctl stop NetworkManager
sudo systemctl disable NetworkManager

# Bring down and set up wlan0 in IBSS (ad-hoc) mode
echo "Bringing down wlan0..."
sudo ip link set wlan0 down
sudo iw wlan0 set type ibss
sudo ip link set wlan0 up

echo "Joining ad hoc network PiAdHocNet on channel 2412..."
sudo iw wlan0 ibss join PiAdHocNet 2412

# Assign the IP address
echo "Assigning IP address: $IP"
sudo ip addr flush dev wlan0
sudo ip addr add "$IP" dev wlan0
sudo ip link set wlan0 up

echo "✅ wlan0 is up and connected. IP assigned: $IP"
iw dev wlan0 info

# === 3. Run the Sender Script ===
# The sender script should be in the current directory
echo "🚀 Running sender script..."

# Default GPIO pin for DHT11 (can be passed as the second argument)
GPIO_PIN=${2:-4}  # Default to GPIO 4 if not provided

# Run the sender script (ensure it is executable)
chmod +x sender_pi_setup.sh
./sender_pi_setup.sh --data "$GPIO_PIN"

# Optional: deactivate the virtual environment after execution (if needed)
deactivate
