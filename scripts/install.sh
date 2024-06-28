#!/bin/bash

source helper_functions.sh

CURRENT_USER="$(logname)"

# Enable debugging output
set -x

sudo apt-get update -y
sudo apt-get upgrade -y

# Install required packages
sudo apt-get install --no-install-recommends wayfire wlroots wtype chromium-browser xscreensaver rpicam-apps libcamera-tools seatd xdg-user-dirs

# Check if Docker is installed, install if not
if ! command_exists docker; then
    curl -fsSL https://get.docker.com | sh
fi

# Add current user to the docker group
usermod -aG docker "$CURRENT_USER"

# Refresh permissions for docker
newgrp docker

docker_method=$(display_install_menu)

# Set variables
KIOSK_URL="http://127.0.0.1:3000"
WAYFIRE_INI="$HOME/.config/wayfire.ini"
BASH_PROFILE="$HOME/.bash_profile"
SYSTEM_MOTION_CONF="/etc/motion/motion.conf"
MOTION_DAEMON_FILE="/etc/default/motion"
USER_MOTION_CONF="$HOME/.motion/motion.conf"
USER_CAMERA_CONF="$HOME/.motion/camera1.conf"
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

chmod +x "$SCRIPT_DIR/run.sh"

sudo cp ./docker/* /etc/systemd/system/

case $docker_method in
    1)
        systemctl enable smarty-docker-hub-api
        systemctl enable smarty-docker-hub-client

# Define auto start commands, includes "motion -n" to start motion on openbox startup
WAYFIRE_AUTOSTART_SETTINGS=(
    "kioskUrl = export KIOSK_URL=\"http://127.0.0.1:3000\""
    "cleanExitLocalState = sed -i 's/\"exited_cleanly\":false/\"exited_cleanly\":true/' ~/.config/chromium/'Local State'"
    "cleanExitPrefs = sed -i 's/\"exited_cleanly\":false/\"exited_cleanly\":true/; s/\"exit_type\":\"[^\"]\+\"/\"exit_type\":\"Normal\"/' ~/.config/chromium/Default/Preferences"
    "mirrorAPI = docker run -d --rm --name dermi-mirror-api -v \"$(pwd)/../config:/usr/src/app/config\" -e NODE_ENV=production -p 5000:5000 timfentoncortina/dermi-mirror-api:latest"
    "mirrorClient = docker run -d --rm --name dermi-mirror-client -v \"$(pwd)/../config:/usr/src/app/config\" -e NODE_ENV=production -p 3000:3000 timfentoncortina/dermi-mirror-client:latest"
    "chromium = chromium-browser $KIOSK_URL --kiosk --disable-gpu --noerrdialogs --disable-infobars --no-first-run --ozone-platform=wayland --enable-features=OverlayScrollbar --start-maximized"
    "motion = motion -n"
)

WAYFIRE_CORE_SETTINGS=(
    "plugins = alpha animate autostart autostart-static command pixdecor expo fast-switcher fisheye grid idle invert move oswitch place resize switcher vswitch window-rules wm-actions wrot zoom winshadows"
)

WAYFIRE_IDLE_SETTINGS=(
    "screensaver = true"
    "screensaver_timeout = 30"
    "dpms = false"
    "disable_on_fullscreen = false"
)

touch "$WAYFIRE_INI"

# Append or update wayfire [autostart] section
append_or_update_section "autostart" "${WAYFIRE_AUTOSTART_SETTINGS[@]}"

# Append or update wayfire [core] section
append_or_update_section "core" "${WAYFIRE_CORE_SETTINGS[@]}"

# Append or update wayfire [idle] section
append_or_update_section "idle" "${WAYFIRE_IDLE_SETTINGS[@]}"


touch "$BASH_PROFILE"

# Define environment variable dictionary
declare -A ENV_VAR_ARRAY
ENV_VAR_ARRAY["KIOSK_URL"]=$KIOSK_URL

# Iterate over env vars and add to bash profile first, to ensure commands dont block setting vars
for key in "${ENV_VAR_ARRAY[@]}"; do
    var_name="$key"
    var_value="${ENV_VAR_ARRAY[$key]}"
    
    if ! grep -q "export $var_name=" "$BASH_PROFILE"; then
        echo "export $var_name=\"$var_value\"" >> "$BASH_PROFILE"
        echo "Added '$var_name' to $BASH_PROFILE"
    else 
        sed -i "s/^export $var_name=.*/export $var_name=\"$var_value\"/" "$BASH_PROFILE"
        echo "Updated '$var_name' in $BASH_PROFILE"
    fi
done

# Define bash profile commands, includes "startx" to start x server if not running
BASHPROFILE_CMD_ARRAY=(
    "[[ -z \"$DISPLAY\" && \"$XDG_VTNR\" -eq 1 ]] && startx"
)

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


if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    display_ssh_menu
else
    display_local_menu
fi