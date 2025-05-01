import socket
import time
import argparse
import adafruit_dht
import board
import sys

parser = argparse.ArgumentParser(description="Send DHT11 data over UDP broadcast")
parser.add_argument("--data", type=int, required=True, help="GPIO pin connected to DHT11 data")
args = parser.parse_args()

# === GPIO Pin Mapping ===
gpio_map = {
    4: board.D4,
    17: board.D17,
    
}

if args.data not in gpio_map:
    print(f"[ERROR] Unsupported GPIO pin {args.data}. Supported pins: {list(gpio_map.keys())}")
    sys.exit(1)

PIN = gpio_map[args.data]
dhtDevice = adafruit_dht.DHT11(PIN)

# === Network Config ===
BROADCAST_IP = "192.168.199.255"  
PORT = 5005

# === Setup UDP Broadcast Socket ===
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)

print(f"[INFO] Broadcasting DHT11 readings from GPIO{args.data} to {BROADCAST_IP}:{PORT}... (Ctrl+C to stop)")

try:
    while True:
        temperature = None
        humidity = None
        for attempt in range(3):  # Retry logic
            try:
                temperature = dhtDevice.temperature
                humidity = dhtDevice.humidity
                if temperature is not None and humidity is not None:
                    break
            except RuntimeError as e:
                print(f"[WARN] Read failed (attempt {attempt + 1}/3): {e}")
                time.sleep(2)
        
        if temperature is not None and humidity is not None:
            message = f"{temperature:.1f},{humidity:.1f}"
            sock.sendto(message.encode(), (BROADCAST_IP, PORT))
            print(f"[OK] Sent: {message}")
        else:
            print("[ERROR] Sensor failed after 3 attempts.")

        time.sleep(3)

except KeyboardInterrupt:
    print("\n[INFO] Sender stopped by user.")

finally:
    dhtDevice.exit()
    sock.close()
