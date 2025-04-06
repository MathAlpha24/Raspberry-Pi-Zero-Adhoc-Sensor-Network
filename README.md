sudo systemctl stop wpa_supplicant
sudo systemctl disable wpa_supplicant
sudo systemctl stop NetworkManager
sudo systemctl disable NetworkManager

sudo ip link set wlan0 down
sudo ip link set wlan0 up

sudo iw wlan0 set type ibss

sudo iw wlan0 ibss join PiAdHocNet 2412
sudo ip link set wlan0 up
sudo ip addr add 192.168.2.x/24 dev wlan0 # Each Pi needs a diffrent address

iw dev wlan0 info

ping 192.168.2.x
