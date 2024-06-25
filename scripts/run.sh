# Run the server and launch chromium ( if you need to relaunch without reboot )

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

docker run -d --name dermi-mirror-api \
  -v "$(pwd)/../config/server.json:/usr/src/app/server.json" \
  -e NODE_ENV=production \
  -p 5000:5000 \
  timfentoncortina/dermi-mirror-api:latest

docker run -d --name dermi-mirror-client \
  -v "$(pwd)/../config/layout.json:/usr/src/app/mirror_config.json" \
  -e NODE_ENV=production \
  -p 5000:5000 \
  timfentoncortina/dermi-mirror-client:latest

chromium-browser  --noerrdialogs --disable-infobars --kiosk \"$KIOSK_URL\"

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