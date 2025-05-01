# Raspberry-Pi-Zero-Adhoc-Sensor-Network
Created for ECE 4990 Celluar Systems CPP Class Project

This project uses Raspberry Pi Lite OS and compatible boards.
## How to Set Up Pi (both reciever and sender)

1. Internet Setup
```
sudo raspi-config #open settings and connect to internet.
```
2. Install all updates 
```
sudo apt update && sudo apt upgrade -y
```
3. Install python 3 (should be already installed with Raspberry Pi Lite OS)
```
python3 --version #check to see if python3 is installed
sudo apt install python3 -y #install if python3 is not installed
```
4. Install git
```
git --version #check to see if git is installed
sudo apt install git -y #install if git is not installed
```
5. Install pip3
```
pip3 --version #check to see if pip3 is installed
sudo apt install python3-pip -y #install if pip3 is not installed
```
6. clone git repository
```
git clone https://github.com/MathAlpha24/Raspberry-Pi-Zero-Adhoc-Sensor-Network.git
cd Raspberry-Pi-Zero-Adhoc-Sensor-Network/scripts
```
If you need to rejoin the folder location for whatever reason:
```
cd ~/Raspberry-Pi-Zero-Adhoc-Sensor-Network
git fetch origin
git checkout -b batman origin/batman #for this branch
git pull origin batman

```
## Switching Branches (Testing Purposes)
```
cd ~/Raspberry-Pi-Zero-Adhoc-Sensor-Network/scripts
```
## Running the Sender Pi
Connect the pins of the DHT11 as follows:
* VCC Pin to 5V on Pi (Pins )
* GND pin to GND on Pi (Pins)
* Data Pin to any GPIO pins
    * Keep note of the GPIO pin used as it will be used as an argument for the bash script to set up the receiver
    * The script defaults to GPIO 4.

Run the following command
```
chmod +x sender_pi_setup.sh
chmod +x sender_pi_start.sh
```
Run the `sender_pi_setup.sh ` at start (make sure you are connected to the internet)
```
./sender_pi_setup.sh <.x of 192.168.2.x> [GPIO pin]
```
><.x of 192.168.2.x> is a required argument. It sets up the IP address of the Pi. Make sure it is a unique address different from other Pi's in the adhoc system

> The [GPIO pin] argument is optional if you used a different pin than GPIO 4. Leave blank if data pin of DHT11 is connected to GPIO 4.

>ex: `./sender_pi_start.sh 1` 
>* IP address of 192.168.2.**1**
>* GPIO pin 4 (since its left blank)

Run the `sender_pi_start.sh` every other time (internet not required)
```
./sender_pi_start.sh <.x of 192.168.2.x> [GPIO pin] #same arguments as sender_pi_setup.sh
```

## Running the Receiever Pi
DHT11 is not required for the Reciever Pi
Run the following command
```
chmod +x receiver_pi_setup.sh
chmod +x receiver_pi_start.sh
```
Run the `receiver_pi_setup.sh ` at start (make sure you are connected to the internet)
```
./receiver_pi_setup.sh <.x of 192.168.2.x> 
```
><.x of 192.168.2.x> is a required argument. It sets up the IP address of the Pi. Make sure it is a unique address different from other Pi's in the adhoc system

>ex: `./receiver_pi_start.sh 1` 
>* IP address of 192.168.2.**1**


Run the `receiver_pi_start.sh` every other time (internet not required)
```
./receiver_pi_start.sh <.x of 192.168.2.x>  #same arguments as receiver_pi_setup.sh
```

## Setting up Wi-Fi Again
To connect back the internet to update files, run the following commands in the `/Raspberry-Pi-Zero-Adhoc-Sensor-Network/scripts` folder.
Run the following commands
```
chmod +x enable_wifi.sh
./enable_wifi.sh "YourSSID" "YourPassword"
```

