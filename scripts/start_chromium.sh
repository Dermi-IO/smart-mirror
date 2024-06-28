#!/bin/bash

KIOSK_URL="https://127.0.0.1:3000"

# Wait for the service to be available
while ! curl -s "$KIOSK_URL" > /dev/null; do
    echo "Waiting for the service to be available..."
    sleep 2
done

echo "Service is up. Launching Chromium."

# Launch Chromium in kiosk mode
chromium-browser "$KIOSK_URL" --kiosk --noerrdialogs --disable-infobars --no-first-run --ozone-platform=wayland --enable-features=OverlayScrollbar --start-maximized "http://localhost:3000"