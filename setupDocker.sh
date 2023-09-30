#!/bin/bash

SUCCESS_CODE=0
NON_SUDO_ERROR_CODE=1
DOCKER_INSTALLATION_ERROR_CODE=2

DOCKER_DAEMON_FILE_PATH="/etc/docker/daemon.json"
DOCKER_PACKAGE_NAME="docker.io"
DOCKER_SERVICE_NAME="docker.service"

echo "┌─────────────────────────────────────────────────┐"
echo "│▛▀▖      ▌         ▌  ▗           ▞▀▖   ▐        │"
echo "│▌ ▌▞▀▖▞▀▖▌▗▘▞▀▖▙▀▖ ▌  ▄ ▛▀▖▌ ▌▚▗▘ ▚▄ ▞▀▖▜▀ ▌ ▌▛▀▖│"
echo "│▌ ▌▌ ▌▌ ▖▛▚ ▛▀ ▌   ▌  ▐ ▌ ▌▌ ▌▗▚  ▖ ▌▛▀ ▐ ▖▌ ▌▙▄▘│"
echo "│▀▀ ▝▀ ▝▀ ▘ ▘▝▀▘▘   ▀▀▘▀▘▘ ▘▝▀▘▘ ▘ ▝▀ ▝▀▘ ▀ ▝▀▘▌  │"
echo "└─────────────────────────────────────────────────┘"

if [ "$EUID" -ne 0 ]
  then echo -e "\t\tPlease run as root"
  exit $NON_SUDO_ERROR_CODE
fi

apt-get update
apt-get install $DOCKER_PACKAGE_NAME -y

if [ -x "$(command -v docker)" ]; then
    echo "Docker installed."
else
    echo -e "Error installing docker.\nAbort"
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
        echo -e "Rebooting...\n"
        sleep 1
        reboot
else
        echo -e "Don't forget to reboot before using docker!\n"
        exit $SUCCESS_CODE
fi