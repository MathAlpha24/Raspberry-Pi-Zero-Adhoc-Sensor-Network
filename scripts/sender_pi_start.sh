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

LAST_OCTET="$1"
GPIO_PIN="${2:-4}"  # Default GPIO pin is 4

ADHOC_IP="192.168.2.$LAST_OCTET/24"
BATMAN_IP="192.168.199.$LAST_OCTET/24"

echo "Stopping NetworkManager..."
sudo systemctl stop NetworkManager || true
sudo systemctl disable NetworkManager || true

echo "Configuring $IFACE for ad-hoc mode..."
sudo ip link set "$IFACE" down
sudo iw "$IFACE" set type ibss
sudo ip link set "$IFACE" up
sudo iw "$IFACE" ibss join PiAdHocNet 2412

# === 3. BATMAN-adv Setup ===
echo "[INFO] Loading BATMAN-adv kernel module..."
sudo modprobe batman-adv
echo "batman-adv" | sudo tee -a /etc/modules >/dev/null

echo "[INFO] Adding $IFACE to batman-adv..."
sudo batctl if add "$IFACE"
sudo ip link set up dev bat0
sudo ip link set up dev "$IFACE"

echo "[INFO] Assigning IP to bat0 interface..."
sudo ip addr flush dev bat0
sudo ip addr add "$BATMAN_IP" dev bat0

echo "[INFO] BATMAN neighbor table:"
sudo batctl n || true
echo "[INFO] BATMAN originator table:"
sudo batctl o || true

# === 4. Run the Python DHT11 Sender Script ===
echo "Running DHT11 sender Python script on GPIO $GPIO_PIN..."
cd "$PROJECT_DIR"
python3 dht11_sender.py --data "$GPIO_PIN"

# === 5. Deactivate Virtual Environment ===
deactivate
