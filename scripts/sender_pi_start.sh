#!/bin/bash

set -e  # Exit on any error

# === 0. Confirm We're in the Correct Folder ===
if [ ! -f "Raspberry-Pi-Zero-Adhoc-Sensor-Network/scripts/dht11_sender.py" ]; then
    echo " Error: This script must be run from the folder containing the 'Raspberry-Pi-Zero-Adhoc-Sensor-Network/scripts/' directory."
    exit 1
fi

# === 1. Activate the Virtual Environment ===
echo "Activating virtual environment..."

PROJECT_DIR=~/sensor_project
VENV_DIR=$PROJECT_DIR/venv

if [ ! -d "$VENV_DIR" ]; then
    echo "Virtual environment not found at $VENV_DIR. Please set it up first."
    exit 1
fi

source "$VENV_DIR/bin/activate"

# === 2. Set Up the Ad-Hoc Network ===
echo "📡 Setting up ad hoc Wi-Fi network..."

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

# === 3. Run the Python DHT11 Sender Script ===
echo "Running DHT11 sender Python script..."

GPIO_PIN=${2:-4}  # Default to GPIO 4 if second argument not given

cd "$PROJECT_DIR/Raspberry-Pi-Zero-Adhoc-Sensor-Network/scripts"
python3 dht11_sender.py --data "$GPIO_PIN"

# === 4. Deactivate the Virtual Environment ===
deactivate
