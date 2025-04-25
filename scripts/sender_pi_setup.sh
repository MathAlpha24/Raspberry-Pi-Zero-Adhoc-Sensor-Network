#!/bin/bash

# === 0. IP Config ===
if [ -z "$1" ]; then
    echo "Usage: $0 <last-octet-of-IP>"
    exit 1
fi

LAST_OCTET=$1
IP="192.168.2.$LAST_OCTET/24"

# === 1. Ad Hoc Wi-Fi Setup ===
echo "📡 Setting up ad hoc Wi-Fi network..."

echo "Stopping NetworkManager..."
sudo systemctl stop NetworkManager
sudo systemctl disable NetworkManager

echo "Restarting wlan0..."
sudo ip link set wlan0 down
sudo iw wlan0 set type ibss
sudo ip link set wlan0 up

echo "Joining ad hoc network PiAdHocNet on channel 2412..."
sudo iw wlan0 ibss join PiAdHocNet 2412

echo "Assigning IP: $IP"
sudo ip addr flush dev wlan0  # Clear existing IPs
sudo ip addr add "$IP" dev wlan0

echo "✅ wlan0 status:"
iw dev wlan0 info

# === 2. Project and VENV Setup ===
PROJECT_DIR=~/sensor_project
VENV_DIR=$PROJECT_DIR/venv
GIT_REPO="https://github.com/MathAlpha24/Raspberry-Pi-Zero-Adhoc-Sensor-Network.git"
GIT_BRANCH="adhoc_tst"
PYTHON_SCRIPT="dht11_sender.py"
GPIO_PIN=4  # Default GPIO pin for DHT11

echo "📁 Creating project directory and virtual environment..."
sudo apt update
sudo apt install -y python3 python3-venv python3-pip git

mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"
python3 -m venv venv

echo "🌱 Activating venv..."
source "$VENV_DIR/bin/activate"

# === 3. Install Adafruit_DHT if needed ===
echo "📦 Checking for Adafruit_DHT..."
python3 -c "import Adafruit_DHT" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "Installing Adafruit_DHT..."
    pip install Adafruit_DHT
else
    echo "✅ Adafruit_DHT already installed."
fi

# === 4. Clone Repo and Run Script ===
echo "⬇️ Cloning project repo..."
cd "$PROJECT_DIR"
rm -rf Raspberry-Pi-Zero-Adhoc-Sensor-Network
git clone -b "$GIT_BRANCH" "$GIT_REPO"
cd Raspberry-Pi-Zero-Adhoc-Sensor-Network

echo "🚀 Running DHT11 sender script..."
python3 "$PYTHON_SCRIPT" --data "$GPIO_PIN"

# Optional: deactivate after exit
deactivate
