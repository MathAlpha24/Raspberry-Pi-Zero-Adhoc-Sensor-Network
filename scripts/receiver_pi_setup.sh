#!/bin/bash
# Script to set up a Pi to receive DHT11 data over ad hoc network.
# Installs dependencies, sets up ad hoc Wi-Fi, and runs the receiver.
set -e  # Exit on any error

# === 1. Install Required Libraries ===
echo "Installing required dependencies..."

# Update package list and install necessary tools and libraries
sudo apt update
sudo apt install -y python3 python3-venv python3-pip git iw build-essential python3-dev libgpiod2

# === 2. Set Up the Virtual Environment ===
echo "Setting up virtual environment..."

# Create project directory and set up virtual environment
PROJECT_DIR=~/receiver_project
VENV_DIR=$PROJECT_DIR/venv

# Create project directory if it doesn't exist
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Create and activate the virtual environment
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

# Update pip and install Python dependencies inside the virtual environment
echo "Installing Python packages inside the virtual environment..."
pip install --upgrade pip

# Copy Project Files
echo "Copying project files into the project directory..."

# Return to the original script folder
cd -

# Copy everything except any venv that might exist
rsync -av --exclude 'venv' ./ "$PROJECT_DIR/"

cd "$PROJECT_DIR"

# === 3. Set Up the Ad-Hoc Network ===
echo "📡 Setting up ad hoc Wi-Fi network..."

# Make sure you have the last octet as the first argument
if [ -z "$1" ]; then
    echo "Usage: $0 <last-octet-of-IP>"
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

# === 5. Run the Python DHT11 Receiver Script ===
echo "Running DHT11 receiver Python script..."

# Go to the project folder where python script was copied to.
cd "$PROJECT_DIR"
python3 dht11_receiver.py

# Deactivate virtual environment after execution
deactivate
