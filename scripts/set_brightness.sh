```bash
#!/usr/bin/env bash
set -euo pipefail

TARGET_BRIGHTNESS="${1:-0.35}"
export DISPLAY=:0
export XAUTHORITY="/home/stevie/.Xauthority"

sleep 3
xrandr --output DP-3 --brightness "$TARGET_BRIGHTNESS"
