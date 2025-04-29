import socket
import time
import argparse
import adafruit_dht
import board

# === Command-line Argument Parser ===
parser = argparse.ArgumentParser(description="Send DHT11 data over UDP broadcast")
parser.add_argument("--data", type=int, required=True, help="GPIO pin connected to DHT11 data")
args = parser.parse_args()

# === Configuration ===
# Mapping BCM GPIO number to board pin
gpio_pin = args.data
if gpio_pin == 4:
    PIN = board.D4
elif gpio_pin == 17:
    PIN = board.D17
else:
    raise ValueError("Only GPIO4 and GPIO17 currently mapped. Expand as needed.")

dhtDevice = adafruit_dht.DHT11(PIN)

BROADCAST_IP = "192.168.2.255"
PORT = 5005

# === Setup socket for broadcast ===
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)

print(f"Broadcasting DHT11 readings from GPIO{gpio_pin} on {BROADCAST_IP}:{PORT}... (Ctrl+C to stop)")

try:
    while True:
        try:
            temperature = dhtDevice.temperature
            humidity = dhtDevice.humidity

            if humidity is not None and temperature is not None:
                message = f"{temperature:.1f},{humidity:.1f}"
                sock.sendto(message.encode(), (BROADCAST_IP, PORT))
                print(f"Sent: {message}")
            else:
                print("Sensor read failed. Retrying...")
        except Exception as e:
            print(f"Read error: {e}")

        time.sleep(3)

except KeyboardInterrupt:
    print("\nStopped by user.")
    sock.close()
