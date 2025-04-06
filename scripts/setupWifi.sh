#!/bin/bash

# Enable NetworkManager service
sudo systemctl enable NetworkManager

# Start NetworkManager service
sudo systemctl start NetworkManager

# Initialize counter for timeout
counter=0

# Try to ping google.com every 1 second, timeout after 20 seconds
while [ $counter -lt 20 ]; do
    # Ping google.com with 1 second timeout and suppress output
    if ping -c 1 -W 1 google.com > /dev/null 2>&1; then
        echo "Successfully connected to google.com!"
        exit 0
    fi
    
    # Increment counter
    ((counter++))
    
    # Wait for 1 second before retrying
    sleep 1
done

# If we reach here, it means the ping failed after 20 attempts
echo "Failed to connect to google.com after 20 seconds."
exit 1
