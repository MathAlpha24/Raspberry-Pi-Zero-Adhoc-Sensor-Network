import socket
import time
import argparse
import adafruit_dht
import board
import sys

# === Command-line Argument Parser ===
parser = argparse.ArgumentParser(description="Send DHT11 data over UDP broadcast")
parser.add_argument("--data", type=int, required=True, help="GPIO pin connected to DHT11 data")
args = parser.parse_args()

# === GPIO Pin Mapping ===
gpio_map = {
    4: board.D4,
    17: board.D17,
    # Add more GPIO to board pin mappings if needed
}

if args.data not in gpio_map:
    print(f"Unsupported GPIO pin {args.data}. Supported pins: {list(gpio_map.keys())}")
    sys.exit(1)

PIN = gpio_map[args.data]
dhtDevice = adafruit_dht.DHT11(PIN)

# === Network Config ===
BROADCAST_IP = "192.168.2.255"
PORT = 5005

# === Setup UDP Broadcast Socket ===
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)

print(f" Broadcasting DHT11 readings from GPIO{args.data} to {BROADCAST_IP}:{PORT}... (Ctrl+C to stop)")

try:
    while True:
        try:
            temperature = dhtDevice.temperature
            humidity = dhtDevice.humidity

            if humidity is not None and temperature is not None:
                message = f"{temperature:.1f},{humidity:.1f}"
                sock.sendto(message.encode(), (BROADCAST_IP, PORT))
                print(f" Sent: {message}")
            else:
                print("Sensor read failed. Retrying...")

        except RuntimeError as e:
            print(f"Sensor read error: {e}")
        except Exception as e:
            print(f"Unhandled exception: {e}")

        time.sleep(3)

except KeyboardInterrupt:
    print("\n Sender stopped by user.")

finally:
    dhtDevice.exit()
    sock.close()
