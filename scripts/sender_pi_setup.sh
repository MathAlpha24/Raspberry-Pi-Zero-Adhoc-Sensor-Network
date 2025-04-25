#!/bin/bash

set -e  # Exit on any error

# === 1. Install Required Libraries ===
echo "Installing required dependencies..."

# Update package list and install necessary tools and libraries
sudo apt update
sudo apt install -y python3 python3-venv python3-pip git iw build-essential python3-dev libgpiod2

# === 2. Set Up the Virtual Environment ===
echo "Setting up virtual environment..."

# Create project directory and set up virtual environment
PROJECT_DIR=~/sensor_project
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
pip install adafruit-circuitpython-dht
pip install RPI.GPIO

# === 3. Set Up the Ad-Hoc Network ===
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

echo "wlan0 is up and connected. IP assigned: $IP"
iw dev wlan0 info

# === 4. Run the Python DHT11 Sender Script ===
echo "📤 Running DHT11 sender Python script..."

# Default GPIO pin for DHT11 (can be passed as the second argument)
GPIO_PIN=${2:-4}  # Default to GPIO 4 if not provided

# Clone or update the project repo if not already done
cd "$PROJECT_DIR"
if [ ! -d "Raspberry-Pi-Zero-Adhoc-Sensor-Network" ]; then
    git clone -b adhoc_tst https://github.com/MathAlpha24/Raspberry-Pi-Zero-Adhoc-Sensor-Network.git
else
    cd Raspberry-Pi-Zero-Adhoc-Sensor-Network
    git pull origin adhoc_tst
    cd ..
fi

# Go to the script folder and run the sender script
cd Raspberry-Pi-Zero-Adhoc-Sensor-Network
python3 dht11_sender.py --data "$GPIO_PIN"

# Optional: deactivate virtual environment after execution
deactivate
