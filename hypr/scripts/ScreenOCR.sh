#!/bin/bash

IMG=$(mktemp /tmp/screenocr_XXXX.png)

grim -g "$(slurp)" "$IMG"

TEXT=$(tesseract "$IMG" stdout -l eng 2>/dev/null)

echo "$TEXT" | wl-copy

notify-send "OCR Complete" "$(echo "$TEXT" | head -c 120)"

rm "$IMG"