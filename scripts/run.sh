#!/bin/bash
# Run the server and launch chromium (if you need to relaunch without reboot)

# Helper functions

check_docker_image() {
    docker images "$1" | grep -q "$1"
    if [ $? -eq 0 ]; then
        echo "Docker image $1 is already pulled."
    else
        echo "Docker image $1 is not pulled."
        echo "Pulling Docker image $1..."
        docker pull "$1"
        if [ $? -eq 0 ]; then
            echo "Docker image $1 pulled successfully."
        else
            echo "Failed to pull Docker image $1. Please check your Docker installation and network connection."
            exit 1
        fi
    fi
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

wait_for_service() {
    local url="$1"
    local retries=30
    local wait=2
    for i in $(seq 1 $retries); do
        if curl -s "$url" > /dev/null; then
            echo "Service is up and running at $url."
            return 0
        fi
        echo "Waiting for service at $url to be available..."
        sleep $wait
    done
    echo "Service at $url did not become available after $((retries * wait)) seconds."
    exit 1
}

# Check if Docker is installed
if ! command_exists docker; then
    echo "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Chromium is installed
if ! command_exists chromium-browser; then
    echo "Chromium is not installed. Please install Chromium first."
    exit 1
fi

# Define the image names or tags to check
DERMI_MIRROR_API="timfentoncortina/dermi-mirror-api:latest"
DERMI_MIRROR_CLIENT="timfentoncortina/dermi-mirror-client:latest"

check_docker_image "$DERMI_MIRROR_API"
check_docker_image "$DERMI_MIRROR_CLIENT"

# Check if containers are already running and stop them
if [ $(docker ps -q -f name=dermi-mirror-api) ]; then
    docker stop dermi-mirror-api
    docker rm dermi-mirror-api
fi

if [ $(docker ps -q -f name=dermi-mirror-client) ]; then
    docker stop dermi-mirror-client
    docker rm dermi-mirror-client
fi

# Start the containers
docker run -d --name dermi-mirror-api \
  -v "$(pwd)/../config/server.json:/usr/src/app/server.json" \
  -e NODE_ENV=production \
  -p 5000:5000 \
  timfentoncortina/dermi-mirror-api:latest

docker run -d --name dermi-mirror-client \
  -v "$(pwd)/../config/mirror_config.json:/usr/src/app/mirror_config.json" \
  -e NODE_ENV=production \
  -p 3000:3000 \
  timfentoncortina/dermi-mirror-client:latest

KIOSK_URL="http://localhost:3000"

wait_for_service "$KIOSK_URL"

# Run Chromium as the logged-in user
chromium-browser "$KIOSK_URL" --kiosk --disable-gpu --noerrdialogs --disable-infobars --no-first-run --ozone-platform=wayland --enable-features=OverlayScrollbar --start-maximized