import Adafruit_DHT
import socket
import time
import argparse

# === Command-line Argument Parser ===
parser = argparse.ArgumentParser(description="Send DHT11 data over UDP broadcast")
parser.add_argument("--data", type=int, required=True, help="GPIO pin connected to DHT11 data")
args = parser.parse_args()

# === Configuration ===
DHT_SENSOR = Adafruit_DHT.DHT11
DHT_PIN = args.data
BROADCAST_IP = "192.168.1.255"  # Adjust for your ad hoc subnet
PORT = 5005

# === Setup socket for broadcast ===
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)

print(f"Broadcasting DHT11 readings from GPIO{DHT_PIN} on {BROADCAST_IP}:{PORT}... (Ctrl+C to stop)")

try:
    while True:
        humidity, temperature = Adafruit_DHT.read(DHT_SENSOR, DHT_PIN)

        if humidity is not None and temperature is not None:
            message = f"{temperature:.1f},{humidity:.1f}"
            sock.sendto(message.encode(), (BROADCAST_IP, PORT))
            print(f"Sent: {message}")
        else:
            print("Sensor read failed. Retrying...")

        time.sleep(3)

except KeyboardInterrupt:
    print("\nStopped by user.")
    sock.close()
