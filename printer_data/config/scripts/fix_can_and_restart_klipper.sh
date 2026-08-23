#!/bin/bash
set -e

echo "Resetting can0..."
/sbin/ip link set can0 down 2>/dev/null || true
sleep 1
/sbin/ip link set can0 up type can bitrate 1000000
/sbin/ip link set can0 txqueuelen 1024 2>/dev/null || true

echo "Waiting briefly for CAN bus..."
sleep 2

echo "Checking CAN devices..."
/home/bryan/klippy-env/bin/python /home/bryan/klipper/scripts/canbus_query.py can0 || true

echo "Restarting Klipper..."
/bin/systemctl restart klipper
