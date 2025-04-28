import socket

# === Configuration ===
LISTEN_IP = "0.0.0.0"  # Listen on all available interfaces
PORT = 5005

# === Setup the UDP socket ===
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((LISTEN_IP, PORT))

print(f" Listening for DHT11 data on port {PORT}... (Ctrl+C to stop)")

try:
    while True:
        data, addr = sock.recvfrom(1024)  # Buffer size 1024 bytes
        message = data.decode().strip()
        
        # Expecting format: "temperature,humidity"
        if ',' in message:
            temperature, humidity = message.split(',')
            print(f"  Temp: {temperature}°C,  Humidity: {humidity}% (from {addr[0]})")
        else:
            print(f"⚠  Received malformed data: {message} (from {addr[0]})")

except KeyboardInterrupt:
    print("\n BAD Receiver stopped by user.")
    sock.close()
