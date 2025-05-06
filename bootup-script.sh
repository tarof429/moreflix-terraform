#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

sudo apt update && sudo apt upgrade -y
curl -fsSL https://get.docker.com -o get-docker.sh
chmod +x ./get-docker.sh
sh ./get-docker.sh
sudo usermod -aG docker ubuntu

unset DEBIAN_FRONTEND