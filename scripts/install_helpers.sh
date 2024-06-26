#!/bin/bash

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

select_mode() {
    local mode

    while true; do
        echo "Do you want to use landscape or portrait mode? (l/p)"
        read -r mode

        # Convert user input to lowercase for case-insensitive comparison
        mode=$(echo "$mode" | tr '[:upper:]' '[:lower:]')

        # Check user input and act accordingly
        if [ "$mode" = "l" ] || [ "$mode" = "landscape" ]; then
            mode="landscape"
            break
        elif [ "$mode" = "p" ] || [ "$mode" = "portrait" ]; then
            mode="portrait"
            break
        else
            echo "Invalid choice. Please enter 'l' for landscape or 'p' for portrait."
        fi
    done

    # Store the selected mode in a global variable (optional)
    SELECTED_MODE=$mode
}

# Function to display install menu and get user choice
display_install_menu() {
    echo "Choose an option:"
    echo "1. Install using Docker Hub"
    echo "2. Install using Docker Compose"
    echo "3. Exit"

    read -rp "Enter your choice [1-3]: " choice

    case $choice in
        1) 
            echo "Installing using Docker Hub..."
            install_using_docker_hub  # Execute function directly
            ;;
        2)
            echo "Installing using Docker Compose..."
            install_using_docker_compose  # Execute function directly
            ;;
        3)
            echo "Exiting script..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please enter a number between 1 and 3."
            display_install_menu  # Prompt again if invalid choice
            ;;
    esac

    # Return the user's choice
    echo "$choice"
}

# Display the ssh menu options for the end of the script (ssh install)
display_ssh_menu() {
    echo "Choose an option:"
    echo "1. Reboot the system"
    echo "2. Exit"

    read -rp "Enter your choice [1-2]: " choice

    case $choice in
        1) reboot_system ;;
        2) exit ;;
        *) echo "Invalid choice. Please enter 1 or 2."
           display_menu ;;
    esac
}

# Display the local menu options for the end of the script (non ssh install)
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

reboot_system() {
    echo "Rebooting the system..."
    shutdown -r now
}

# Launch Chromium in kiosk mode in the context of the non-root user
launch_chromium() {
    echo "Launching Chromium..."
    sudo -u "$CURRENT_USER" chromium-browser "http://localhost:3000" --enable-force-dark --kiosk --noerrdialogs --disable-infobars --no-first-run --ozone-platform=wayland --enable-features=OverlayScrollbar --start-maximized
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

install_using_docker_hub() {
    echo "Installing using Docker Hub..."

    # Pull docker images 
    docker pull timfentoncortina/dermi-mirror-api:latest
    docker pull timfentoncortina/dermi-mirror-client:latest
}

install_using_docker_compose() {
    echo "Using Docker Compose..."

    # Install Docker Compose if not installed
    if ! command_exists docker-compose; then
        sudo apt-get install docker-compose-plugin
    fi

    # Pull docker images using Docker Compose
    docker-compose pull

    # Run Docker Compose up -d (assuming you have a docker-compose.yml file configured)
    docker-compose up -d
}