#!/bin/bash

source helper_functions.sh

# Get the user the triggered this, since it was run via sudo we need to do it via logname
CURRENT_USER="$(logname)"

# Prompt the user to ask if they will use landscape or portrait available via SELECTED_MODE
select_mode

# Enable debugging output
set -x

# Make sure we are up to date
sudo apt-get update -y
sudo apt-get upgrade -y

# Install required packages
sudo apt-get install --no-install-recommends \
  chromium-browser \
  libcamera-tools \
  plymouth \
  plymouth-themes \
  rpicam-apps \
  seatd \
  wayfire \
  wlroots \
  wtype \
  xdg-user-dirs \
  xscreensaver

# Check if Docker is installed, install if not
if ! command_exists docker; then
    curl -fsSL https://get.docker.com | sh
fi

# Add current user to the docker group
usermod -aG docker "$CURRENT_USER"

# Refresh permissions for docker
newgrp docker

# Make sure the user owns the .docker dir 
sudo chown -R $CURRENT_USER $HOME/.docker

# Install docker-compose
if ! command_exists docker-compose; then
    sudo apt-get install docker-compose -y
fi

# Build and start docker containers
docker compose up -d

# Start docker on reboot
sudo systemctl enable docker

# Download and place wayfire extra plugins 
wget -qO- https://github.com/WayfireWM/wayfire-plugins-extra/releases/download/v0.8.1/wayfire-plugins-extra-0.8.1.tar.xz | sudo tar -xJ -C /

# Make sure pix is the default theme TODO: make a custom theme
PIX_THEME_DIR="/usr/share/plymouth/themes/pix/"

# Set the default Plymouth theme to 'pix'
sudo plymouth-set-default-theme pix

# Backup the existing splash image
sudo mv "$PIX_THEME_DIR/splash.png" "$PIX_THEME_DIR/splash_bak.png"

# Copy the new splash image to the theme directory
sudo cp -f "./resources/boot/$SELECTED_MODE.png" "$PIX_THEME_DIR/splash.png"

# Update initramfs to apply the changes
sudo update-initramfs -u

# Set variables
KIOSK_URL="http://127.0.0.1:3000"
DEFAULT_WF_INI="./configs/wayfire.ini"
WAYFIRE_INI="$HOME/.config/wayfire.ini"
BASH_RC="$HOME/.bashrc"
CMDLINE_FILE="/boot/cmdline.txt"

# Define environment variable dictionary
CMD_LINE_ARR=(
    "plymouth.ignore-serial-consoles"
    "quiet"
    "splash"
)

# Backup the existing cmdline.txt file
sudo cp "$CMDLINE_FILE" /boot/cmdline_backup.txt

# Check and add entries if they do not exist
for ENTRY in "${CMD_LINE_ARR[@]}"; do
    if ! grep -q "\<$ENTRY\>" "$CMDLINE_FILE"; then
        sudo sed -i "\$s/$/ $ENTRY/" "$CMDLINE_FILE"
    fi
done

# Copy the wayfire.ini over the existing one
cp -f "$DEFAULT_WF_INI" "$WAYFIRE_INI"

# Ensure .bashrc exists
touch "$BASH_RC"

# Define environment variable dictionary
declare -A ENV_VAR_ARRAY
ENV_VAR_ARRAY["KIOSK_URL"]="$KIOSK_URL"
ENV_VAR_ARRAY["WALLPAPER_IMAGE"]="$HOME/smarty/resources/wallpaper/$SELECTED_MODE.png"

# Iterate over env vars and add to bash profile first, to ensure commands dont block setting vars
for key in "${ENV_VAR_ARRAY[@]}"; do
    var_name="$key"
    var_value="${ENV_VAR_ARRAY[$key]}"
    
    if ! grep -q "export $var_name=" "$BASH_RC"; then
        echo "export $var_name=\"$var_value\"" >> "$BASH_RC"
        echo "Added '$var_name' to $BASH_RC"
    else 
        sed -i "s/^export $var_name=.*/export $var_name=\"$var_value\"/" "$BASH_RC"
        echo "Updated '$var_name' in $BASH_RC"
    fi
done

# Define bash profile commands, includes "startx" to start x server if not running
BASHPROFILE_CMD_ARRAY=(
    "[[ -z \"$WAYLAND_DISPLAY\" && \"$XDG_VTNR\" -eq 1 ]] && wayfire --no-cursor"
)

# Add commands to bash profile
for cmd in "${BASHPROFILE_CMD_ARRAY[@]}"; do
    if ! grep -Fxq "$cmd" "$BASH_RC"; then
        echo "$cmd" >> "$BASH_RC"
        echo "Added '$cmd' to $BASH_RC"
    fi
done

if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    display_ssh_menu
else
    display_local_menu
fi