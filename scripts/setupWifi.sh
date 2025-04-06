#!/bin/bash

# Enable NetworkManager service
sudo systemctl enable NetworkManager

# Start NetworkManager service
sudo systemctl start NetworkManager

# Test the network connection by pinging google.com
ping -c 3 google.com

# Check if the ping was successful
if [ $? -eq 0 ]; then
  echo "Network is working, successfully pinged google.com."
else
  echo "Network is not working, failed to ping google.com."
fi
