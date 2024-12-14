#!/bin/bash

# Exit codes
SUCCESS_CODE=0
NON_SUDO_ERROR_CODE=1
DOCKER_INSTALLATION_ERROR_CODE=2

# Constants
DOCKER_DAEMON_FILE_PATH="/etc/docker/daemon.json"
DOCKER_PACKAGE_NAME="docker.io"
DOCKER_SERVICE_NAME="docker.service"

# Colors
COLOR_GREEN="\033[1;32m"
COLOR_RED="\033[1;31m"
COLOR_YELLOW="\033[1;33m"
COLOR_RESET="\033[0m"

# Print banner
echo "┌─────────────────────────────────────────────────┐"
echo "│▛▀▖      ▌         ▌  ▗           ▞▀▖   ▐        │"
echo "│▌ ▌▞▀▖▞▀▖▌▗▘▞▀▖▙▀▖ ▌  ▄ ▛▀▖▌ ▌▚▗▘ ▚▄ ▞▀▖▜▀ ▌ ▌▛▀▖│"
echo "│▌ ▌▌ ▌▌ ▖▛▚ ▛▀ ▌   ▌  ▐ ▌ ▌▌ ▌▗▚  ▖ ▌▛▀ ▐ ▖▌ ▌▙▄▘│"
echo "│▀▀ ▝▀ ▝▀ ▘ ▘▝▀▘▘   ▀▀▘▀▘▘ ▘▝▀▘▘ ▘ ▝▀ ▝▀▘ ▀ ▝▀▘▌  │"
echo "└─────────────────────────────────────────────────┘"

# Check for root privileges
if [ "$EUID" -ne 0 ]
  then echo -e "${COLOR_RED}\t\tPlease run as root${COLOR_RESET}"
  exit $NON_SUDO_ERROR_CODE
fi

# Update package lists and install Docker
apt-get update && apt-get install -y $DOCKER_PACKAGE_NAME
if [ $? -ne 0 ]; then
  echo -e "${COLOR_RED}Failed to update apt packages.${COLOR_RESET}"
  exit $DOCKER_INSTALLATION_ERROR_CODE
fi

if [ -x "$(command -v docker)" ]; then
    echo "Docker installed."
else
    echo -e "${COLOR_RED}Error installing docker.\nAbort${COLOR_RESET}"
    exit $DOCKER_INSTALLATION_ERROR_CODE
fi

touch $DOCKER_DAEMON_FILE_PATH
echo -e '{\n\t"storage-driver":"vfs"\n}\n' > $DOCKER_DAEMON_FILE_PATH
systemctl -q enable $DOCKER_SERVICE_NAME
systemctl -q restart $DOCKER_SERVICE_NAME
usermod -aG docker $SUDO_USER

read -p "Reboot now? [Y/n]" -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
        echo -e "${COLOR_GREEN}Rebooting...\n${COLOR_RESET}"
        sleep 1
        reboot
else
        echo -e "${COLOR_YELLOW}Don't forget to reboot before using docker!\n${COLOR_RESET}"
        exit $SUCCESS_CODE
fi