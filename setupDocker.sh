#!/bin/bash

echo "┌─────────────────────────────────────────────────┐"
echo "│▛▀▖      ▌         ▌  ▗           ▞▀▖   ▐        │"
echo "│▌ ▌▞▀▖▞▀▖▌▗▘▞▀▖▙▀▖ ▌  ▄ ▛▀▖▌ ▌▚▗▘ ▚▄ ▞▀▖▜▀ ▌ ▌▛▀▖│"
echo "│▌ ▌▌ ▌▌ ▖▛▚ ▛▀ ▌   ▌  ▐ ▌ ▌▌ ▌▗▚  ▖ ▌▛▀ ▐ ▖▌ ▌▙▄▘│"
echo "│▀▀ ▝▀ ▝▀ ▘ ▘▝▀▘▘   ▀▀▘▀▘▘ ▘▝▀▘▘ ▘ ▝▀ ▝▀▘ ▀ ▝▀▘▌  │"
echo "└─────────────────────────────────────────────────┘"

if [ "$EUID" -ne 0 ]
  then echo -e "\t\tPlease run as root"
  exit 1
fi

apt-get update
apt-get install docker.io
touch /etc/docker/daemon.json
echo -e "{\n\t"storage-driver":"vfs"\n}\n" > /etc/docker/daemon.json
systemctl -q enable docker.service
systemctl -q restart docker.service
usermod -aG docker $USER

read -p "Reboot now? [Y/n]" -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
        printf "Rebooting...\n"
        sleep 1
        reboot
fi