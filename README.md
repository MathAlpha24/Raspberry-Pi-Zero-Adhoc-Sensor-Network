# Disable Wifi for Adhoc

sudo systemctl stop wpa_supplicant

sudo systemctl disable wpa_supplicant

sudo systemctl stop NetworkManager

sudo systemctl disable NetworkManager

sudo ip link set wlan0 down

sudo ip link set wlan0 up

sudo iw wlan0 set type ibss

sudo iw wlan0 ibss join PiAdHocNet 2412

sudo ip link set wlan0 up

sudo ip addr add 192.168.2.x/24 dev wlan0 # Each Pi needs a diffrent address 192.168.2.2 then 192.168.2.3 then 192.168.2.4

iw dev wlan0 info

ping 192.168.2.x


# Enable WiFi

sudo systemctl enable NetworkManager

sudo systemctl start NetworkManager

ping -c 3 google.com

# Reboot

sudo reboot

# Clone

git clone -b ping https://github.com/MathAlpha24/Raspberry-Pi-Zero-Adhoc-Sensor-Network.git



