#!/bin/bash
set -e

CONF="/home/bryan/printer_data/config/crowsnest.conf"
DIR="$1"
STEP="0.25"

if [ ! -f "$CONF" ]; then
  echo "Missing config: $CONF"
  exit 1
fi

CUR=$(grep '^v4l2ctl:' "$CONF" | grep -o 'LensPosition=[0-9.]*' | cut -d= -f2 || true)
[ -z "$CUR" ] && CUR="0.0"

NEW=$(python3 - <<PY
cur=float("$CUR")
step=float("$STEP")
direction="$DIR"

if direction == "near":
    val = cur + step
elif direction == "far":
    val = cur - step
else:
    raise SystemExit(1)

# Pi camera AF lens range is typically 0..32
val = max(0.0, min(32.0, round(val, 2)))
print(val)
PY
)

sed -i -E "s/^v4l2ctl:.*/v4l2ctl: AfMode=0,LensPosition=$NEW,NoiseReductionMode=1/" "$CONF"
sudo systemctl restart crowsnest
echo "Set LensPosition to $NEW"
