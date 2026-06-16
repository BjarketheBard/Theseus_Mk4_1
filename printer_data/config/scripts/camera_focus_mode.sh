#!/bin/bash
set -e

CONF="/home/bryan/printer_data/config/crowsnest.conf"

MODE="$1"

if [ ! -f "$CONF" ]; then
  echo "Missing config: $CONF"
  exit 1
fi

case "$MODE" in
  auto)
    sed -i -E 's/^v4l2ctl:.*/v4l2ctl: AfMode=2,AfTrigger=0,NoiseReductionMode=1/' "$CONF"
    ;;
  manual)
    # keep existing lens position if present, else default to 0.0
    CUR=$(grep '^v4l2ctl:' "$CONF" | grep -o 'LensPosition=[0-9.]*' | cut -d= -f2 || true)
    [ -z "$CUR" ] && CUR="0.0"
    sed -i -E "s/^v4l2ctl:.*/v4l2ctl: AfMode=0,LensPosition=$CUR,NoiseReductionMode=1/" "$CONF"
    ;;
  *)
    echo "Usage: $0 auto|manual"
    exit 1
    ;;
esac

sudo systemctl restart crowsnest
echo "Set camera mode to $MODE"
