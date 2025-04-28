# How to clone repo

Clone repo
```shell
git clone -b ping https://github.com/MathAlpha24/Raspberry-Pi-Zero-Adhoc-Sensor-Network.git
```
Check branch
```shell
git branch
```
Pull changes from branch
```shell
git pull origin ping
```
# Scripts
## Add Pi, this will also disable WiFi
Go to scripts directory
```shell
cd ~/Raspberry-Pi-Zero-Adhoc-Sensor-Network/scripts
```
Usage example: sh addPi.sh 5

This will set IP="192.168.2.**5**/24"

Usage example: sh addPi.sh 2

This will set IP="192.168.2.**2**/24"
```shell
sh addPi.sh <last-octet>
```
## Delete Pi
Go to scripts directory
```shell
cd ~/Raspberry-Pi-Zero-Adhoc-Sensor-Network/scripts
```
Usage example: sh delPi.sh 5

This will remove IP: 192.168.2.**5**/24 from ad-hoc

Usage example: sh delPi.sh 2

This will remove IP: 192.168.2.**2**/24 from ad-hoc
```shell
sh delPi.sh <last-octet>
```
## Check Ad-hoc
This will list all the IPs on ad-hoc

Make sure it lists only IPs of 192.168.2.**x**/24

If you something else, this is the IP assigned by WiFi
```shell
sh checkAdhoc.sh
```
## Setup WiFi
This will setup WiFi
```shell
sh setupWifi.sh
```
# Reboot Pi
```shell
sudo reboot
```
# Files
Within /boot/firmware/config.txt
add this line at the end:
```shell
dtoverlay=dht11,gpiopin=4
```
This will correspond to GPIO 4, this can be changed to any other GPIO pin

