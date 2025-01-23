#!/bin/bash

# Start ADB server
adb start-server

# Detect the IP address of the container and forward ADB ports
ip=$(hostname -i) # Get the container's IP address
echo "Forwarding ADB ports to external interface on IP: $ip"

socat tcp-listen:5037,bind=$ip,fork tcp:127.0.0.1:5037 &
socat tcp-listen:5554,bind=$ip,fork tcp:127.0.0.1:5554 &
socat tcp-listen:5555,bind=$ip,fork tcp:127.0.0.1:5555 &

# Start the emulator
emulator -avd Pixel -no-window -no-boot-anim -gpu swiftshader_indirect -noaudio -verbose -change-language ru -change-country RU -change-locale ru-RU -timezone Europe/Moscow &

# Wait for the emulator to boot completely
echo "Waiting for the emulator to fully boot..."
adb wait-for-device
sleep 30 # Additional wait time to ensure stability
while [ "$(adb shell getprop sys.boot_completed 2>/dev/null)" != "1" ]; do
    echo "Boot not completed yet. Waiting..."
    sleep 5
done
echo "Emulator boot completed!"

# Download the image
echo "Starting image download..."
wget -O cat.jpg https://cs5.pikabu.ru/images/big_size_comm/2014-09_4/14108546174051.jpg
if [ $? -ne 0 ]; then
    echo "Image download failed."
else
    echo "Image downloaded successfully."
fi

# Wait for the /sdcard to initialize
echo "Waiting for /sdcard/Pictures/ to become writable..."
while ! adb shell ls /sdcard/Pictures/ > /dev/null 2>&1; do
    echo "Storage not ready. Retrying..."
    sleep 2
done
echo "/sdcard/Pictures/ is ready!"

# Push the image to the emulator
for i in {1..5}; do
  adb push cat.jpg /sdcard/Pictures/ && break || echo "Retrying push..."
  sleep 2
done

# Trigger media scan
adb shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file:///sdcard/Pictures/cat.jpg

# Keep the script running
wait
