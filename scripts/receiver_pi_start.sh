#!/bin/bash

set -e  # Exit on any error

# === 1. Set Up Virtual Environment ===
echo "Setting up virtual environment..."

PROJECT_DIR=~/receiver_project
VENV_DIR=$PROJECT_DIR/venv

mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

if [ ! -d "$VENV_DIR" ]; then
    echo "Virtual environment not found. Creating at $VENV_DIR..."
    python3 -m venv "$VENV_DIR"
    source "$VENV_DIR/bin/activate"
else
    source "$VENV_DIR/bin/activate"
fi

# === 2. Set Up the Ad-Hoc Network ===
echo "Setting up ad hoc Wi-Fi network..."

if [ -z "$1" ]; then
    echo "Usage: $0 <last-octet-of-IP> [gpio-pin]"
    exit 1
fi

LAST_OCTET=$1
IP="192.168.2.$LAST_OCTET/24"

echo "Stopping NetworkManager..."
sudo systemctl stop NetworkManager
sudo systemctl disable NetworkManager

echo "Bringing down wlan0..."
sudo ip link set wlan0 down
sudo iw wlan0 set type ibss
sudo ip link set wlan0 up

echo "Joining ad hoc network PiAdHocNet on channel 2412..."
sudo iw wlan0 ibss join PiAdHocNet 2412

echo "Assigning IP address: $IP"
sudo ip addr flush dev wlan0
sudo ip addr add "$IP" dev wlan0
sudo ip link set wlan0 up

echo "wlan0 is up and connected. IP assigned: $IP"
iw dev wlan0 info

# === 3. Run the Python DHT11 Reciever Script ===
echo "Running DHT11 sender Python script..."
# Go to the project folder (assumes the receiver Python script is there)
cd "$PROJECT_DIR"

python3 dht11_receiver.py

# Optional: deactivate virtual environment after execution
deactivate
