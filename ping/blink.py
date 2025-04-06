import RPi.GPIO as GPIO
import os
import time
import threading

LED_PIN = 4
GPIO.setmode(GPIO.BCM)
GPIO.setup(LED_PIN, GPIO.OUT)

# Function to blink LED when pinged
def blink_led():
    GPIO.output(LED_PIN, GPIO.HIGH)
    time.sleep(0.2)
    GPIO.output(LED_PIN, GPIO.LOW)

# Function to listen for pings in the background
def ping_listener():
    while True:
        response = os.system("ping -c 1 192.168.1.2")  # Replace with Pi's IP address (192.168.2.x)
        if response == 0:
            print("Ping received!")
            blink_led()
        time.sleep(1)  # Check for ping every 1 second

# Start the listener in a background thread
ping_thread = threading.Thread(target=ping_listener)
ping_thread.daemon = True
ping_thread.start()

# Keep the script running
try:
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    GPIO.cleanup()
