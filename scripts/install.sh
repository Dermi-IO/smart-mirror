#!/bin/bash
sudo apt-get update -y
sudo apt-get upgrade -y

# Install required packages
sudo apt-get install --no-install-recommends xserver-xorg x11-xserver-utils xinit openbox
sudo apt-get install --no-install-recommends chromium-browser
sudo apt-get install motion

# Set variables
KIOSK_URL="https://www.google.com"
AUTOSTART_FILE="$HOME/.config/openbox/autostart"
ENV_FILE="$HOME/.config/openbox/environment"
BASH_PROFILE="$HOME/.bash_profile"
SYSTEM_MOTION_CONF="/etc/motion/motion.conf"
MOTION_DAEMON_FILE="/etc/default/motion"
USER_MOTION_CONF="$HOME/.motion/motion.conf"
USER_CAMERA_CONF="$HOME/.motion/camera1.conf"

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
    "chromium-browser  --noerrdialogs --disable-infobars --kiosk \"$KIOSK_URL\""
    "motion -n"
)

touch "$AUTOSTART_FILE"

# Add commands to autostart file
for cmd in "${AUTOSTART_CMD_ARRAY[@]}"; do
    if ! grep -Fxq "$cmd" "$AUTOSTART_FILE"; then
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
    if ! grep -Fxq "$var" "$ENV_FILE"; then
        echo "export $var" >> ~/.config/openbox/environment
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
    fi
done

# Copy default configs and wake screen script
cp "./configs/motion.conf" "$USER_MOTION_CONF"
cp "./configs/camera1.conf" "$USER_CAMERA_CONF"
cp "./wake-screen.sh" "$HOME/.motion/"

touch "$MOTION_DAEMON_FILE"

# Configure motion daemon
if grep -Fxq "start_motion_daemon=no" "$MOTION_DAEMON_FILE"; then
    sed -i 's/start_motion_daemon=no/start_motion_daemon=yes/' "$MOTION_DAEMON_FILE"
elif ! grep -Fxq "start_motion_daemon=yes" "$MOTION_DAEMON_FILE"; then
    echo "start_motion_daemon=yes" >> "$MOTION_DAEMON_FILE"
fi