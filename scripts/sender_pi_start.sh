#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# === Variables ===
PROJECT_DIR=~/sensor_project
VENV_DIR="$PROJECT_DIR/venv"
IFACE="wlan0"

# === 1. Set Up Virtual Environment ===
echo "Setting up virtual environment..."

mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

if [ ! -d "$VENV_DIR" ]; then
    echo "Virtual environment not found. Creating at $VENV_DIR..."
    python3 -m venv "$VENV_DIR"
fi

source "$VENV_DIR/bin/activate"

# === 2. Set Up the Ad-Hoc Network ===
echo "📡 Setting up ad hoc Wi-Fi network..."

if [ -z "${1:-}" ]; then
    echo "Usage: $0 <last-octet-of-IP> [gpio-pin]"
    exit 1
fi

LAST_OCTET=$1
ADHOC_IP="192.168.2.$LAST_OCTET/24"
BATMAN_IP="192.168.199.$LAST_OCTET/24"

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

# === 3. BATMAN-adv Setup ===
echo "[INFO] Loading BATMAN-adv kernel module..."
sudo modprobe batman-adv
echo "batman-adv" | sudo tee -a /etc/modules >/dev/null

echo "[INFO] Adding wlan0 to batman-adv..."
sudo batctl if add wlan0
sudo ip link set up dev bat0
sudo ip link set up dev wlan0

echo "[INFO] Assigning IP to bat0 interface..."
sudo ip addr flush dev bat0
sudo ip addr add "$BATMAN_IP" dev bat0

echo "[INFO] BATMAN neighbor table:"
sudo batctl n || true
echo "[INFO] BATMAN originator table:"
sudo batctl o || true


# Default GPIO pin for DHT11 (can be passed as the second argument)
GPIO_PIN=${2:-4}  # Default to GPIO 4 if not provided

cd "$PROJECT_DIR"
python3 dht11_sender.py --data "$GPIO_PIN"

# === 5. Deactivate Virtual Environment ===
deactivate
