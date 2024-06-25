#!/bin/bash

# This script will install using the latest version of the API / Client from docker hub

# Enable debugging output
set -x

sudo apt-get update -y
sudo apt-get upgrade -y

# Install required packages
sudo apt-get install --no-install-recommends xserver-xorg x11-xserver-utils xinit wtype chromium-browser motion xscreensaver

# Check if Docker is installed, install if not
if ! command_exists docker; then
    curl -fsSL https://get.docker.com | sh
fi

# Pull docker images 
docker pull timfentoncortina/dermi-mirror-api:latest
docker pull timfentoncortina/dermi-mirror-client:latest

# Set variables
KIOSK_URL="http://127.0.0.1:3000"
AUTOSTART_FILE="$HOME/.config/openbox/autostart"
ENV_FILE="$HOME/.config/openbox/environment"
BASH_PROFILE="$HOME/.bash_profile"
SYSTEM_MOTION_CONF="/etc/motion/motion.conf"
MOTION_DAEMON_FILE="/etc/default/motion"
USER_MOTION_CONF="$HOME/.motion/motion.conf"
USER_CAMERA_CONF="$HOME/.motion/camera1.conf"
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

chmod +x "$SCRIPT_DIR/run.sh"

# Ensure directories exist
mkdir -p "$HOME/.config/openbox" "$HOME/.motion" "/var/lib/motion"

# Set permissions for motion directory
sudo chgrp motion "/var/lib/motion"
sudo chmod g+rwx "/var/lib/motion"

# Define auto start commands, includes "motion -n" to start motion on openbox startup
AUTOSTART_CMD_ARRAY=(
    "xset -dpms"
    "xset s off"
    "xset s blank"
    "xset s 300"
    "sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' ~/.config/chromium/'Local State'"
    "sed -i 's/\"exited_cleanly\":false/\"exited_cleanly\":true/; s/\"exit_type\":\"[^\"]\+\"/\"exit_type\":\"Normal\"/' ~/.config/chromium/Default/Preferences"
    "docker run -d --name dermi-mirror-api -v \"$(pwd)/../config/server.json:/usr/src/app/server.json\" -e NODE_ENV=production -p 5000:5000 timfentoncortina/dermi-mirror-api:latest"
    "docker run -d --name dermi-mirror-client -v \"$(pwd)/../config/mirror_config.json:/usr/src/app/mirror_config.json\" -e NODE_ENV=production -p 3000:3000 timfentoncortina/dermi-mirror-client:latest"
    "chromium-browser  --noerrdialogs --disable-infobars --kiosk \"$KIOSK_URL\""
    "motion -n"
)

touch "$AUTOSTART_FILE"

# Make sure the autostart file is executable
chmod +x "$AUTOSTART_FILE"

# Add commands to autostart file
for cmd in "${AUTOSTART_CMD_ARRAY[@]}"; do
    if ! grep -Fq "$cmd" "$AUTOSTART_FILE"; then
        # Append " &" to cmd if it's not the last item
        if [[ $index -ne $((array_length - 1)) ]]; then
            cmd="$cmd &"
        fi
        echo "$cmd" >> "$AUTOSTART_FILE"
    fi
done

# Define environment variables
ENV_VAR_ARRAY=(
    "KIOSK_URL=$KIOSK_URL"
)

touch "$ENV_FILE"

# Add environment variables to environment file
for var in "${ENV_VAR_ARRAY[@]}"; do
    if grep -q "^${var%=*}=" "$ENV_FILE"; then
        # If found, update the existing value using sed
        sed -i "s|^${var%=*}=.*|${var}|g" "$ENV_FILE"
        echo "Updated ${var%=*} in $ENV_FILE"
    else
        # If not found, append the variable to the ENV_FILE
        echo "$var" >> "$ENV_FILE"
        echo "Added ${var%=*} to $ENV_FILE"
    fi
done

# Define bash profile commands, includes "startx" to start x server if not running
BASHPROFILE_CMD_ARRAY=(
    "[[ -z \"$DISPLAY\" && \"$XDG_VTNR\" -eq 1 ]] && startx"
)

touch "$BASH_PROFILE"

# Add commands to bash profile
for cmd in "${BASHPROFILE_CMD_ARRAY[@]}"; do
    if ! grep -Fxq "$cmd" "$BASH_PROFILE"; then
        echo "$cmd" >> "$BASH_PROFILE"
        echo "Added '$cmd' to $BASH_PROFILE"
    fi
done

# Copy default configs and wake screen script
cp "./configs/motion.conf" "$USER_MOTION_CONF"
cp "./configs/camera1.conf" "$USER_CAMERA_CONF"
cp "./wake-screen.sh" "$HOME/.motion/"

chmod +x "$HOME/.motion/wake-screen.sh"

touch "$MOTION_DAEMON_FILE"

# Configure motion daemon
if grep -Fxq "start_motion_daemon=no" "$MOTION_DAEMON_FILE"; then
    sed -i 's/start_motion_daemon=no/start_motion_daemon=yes/' "$MOTION_DAEMON_FILE"
elif ! grep -Fxq "start_motion_daemon=yes" "$MOTION_DAEMON_FILE"; then
    echo "start_motion_daemon=yes" >> "$MOTION_DAEMON_FILE"
fi

display_menu

## Helper functions

display_menu() {
    echo "Choose an option:"
    echo "1. Reboot the system"
    echo "2. Launch Chromium"
    echo "3. Exit"

    read -rp "Enter your choice [1-3]: " choice

    case $choice in
        1) reboot_system ;;
        2) launch_chromium ;;
        3) exit ;;
        *) echo "Invalid choice. Please enter a number between 1 and 3."
           display_menu ;;
    esac
}

reboot_system() {
    echo "Rebooting the system..."
    shutdown -r now
}

# Function to launch Chromium
launch_chromium() {
    echo "Launching Chromium..."
    chromium-browser --noerrdialogs --disable-infobars --kiosk "$KIOSK_URL"
}