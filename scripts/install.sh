#!/bin/bash

# This script will install using the latest version of the API / Client from docker hub

CURRENT_USER="$(logname)"

## Helper functions

append_or_update_section() {
    local section_name=$1
    shift
    local settings=("$@")

    # Check if section exists in the INI file
    if grep -q "^\[$section_name\]" "$WAYFIRE_INI"; then
        # Section exists, update its settings
        for setting in "${settings[@]}"; do
            if grep -q "^$setting" "$WAYFIRE_INI"; then
                # Setting already exists, replace it
                sed -i "s/^$setting.*/$setting/" "$WAYFIRE_INI"
            else
                # Setting does not exist, append it below the section header
                sed -i "/^\[$section_name\]/a $setting" "$WAYFIRE_INI"
            fi
        done
    else
        # Section does not exist, append it
        echo "[$section_name]" >> "$WAYFIRE_INI"
        for setting in "${settings[@]}"; do
            echo "$setting" >> "$WAYFIRE_INI"
        done
    fi
}

display_local_menu() {
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

display_ssh_menu() {
    echo "Choose an option:"
    echo "1. Reboot the system"
    echo "2. Exit"

    read -rp "Enter your choice [1-2]: " choice

    case $choice in
        1) reboot_system ;;
        2) exit ;;
        *) echo "Invalid choice. Please enter a number between 1 and 3."
           display_menu ;;
    esac
}

reboot_system() {
    echo "Rebooting the system..."
    shutdown -r now
}

# Launch Chromium in kiosk mode in the context of the non-root user
launch_chromium() {
    echo "Launching Chromium..."
    sudo -u "$CURRENT_USER" chromium-browser --noerrdialogs --disable-infobars --kiosk "$KIOSK_URL"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

### START SCRIPT

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
WAYFIRE_INI="$HOME/.config/wayfire.ini"
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
WAYFIRE_AUTOSTART_SETTINGS=(
    "sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' ~/.config/chromium/'Local State'"
    "sed -i 's/\"exited_cleanly\":false/\"exited_cleanly\":true/; s/\"exit_type\":\"[^\"]\+\"/\"exit_type\":\"Normal\"/' ~/.config/chromium/Default/Preferences"
    "docker run -d --name dermi-mirror-api -v \"$(pwd)/../config/server.json:/usr/src/app/server.json\" -e NODE_ENV=production -p 5000:5000 timfentoncortina/dermi-mirror-api:latest"
    "docker run -d --name dermi-mirror-client -v \"$(pwd)/../config/mirror_config.json:/usr/src/app/mirror_config.json\" -e NODE_ENV=production -p 3000:3000 timfentoncortina/dermi-mirror-client:latest"
    "chromium-browser  --noerrdialogs --disable-infobars --kiosk \"$KIOSK_URL\""
    "sudo -E motion -n"
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


# Define bash profile commands, includes "startx" to start x server if not running
BASHPROFILE_CMD_ARRAY=(
    "[[ -z \"$DISPLAY\" && \"$XDG_VTNR\" -eq 1 ]] && startx"
    "xscreensaver -no-splash"
)

touch "$BASH_PROFILE"

# Add commands to bash profile
for cmd in "${BASHPROFILE_CMD_ARRAY[@]}"; do
    if ! grep -Fxq "$cmd" "$BASH_PROFILE"; then
        echo "$cmd" >> "$BASH_PROFILE"
        echo "Added '$cmd' to $BASH_PROFILE"
    fi
done

# Define environment variable dictionary
declare -A ENV_VAR_ARRAY
ENV_VAR_ARRAY["KIOSK_URL"]=$KIOSK_URL

# Iterate over env vars and add to bash profile
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