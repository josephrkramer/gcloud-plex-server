#!/bin/bash

# Remove Old Repository
sudo rm -fv /etc/apt/sources.list.d/plex*
sudo apt update
sudo apt upgrade -y

# Setup New Repository
# Make sure that curl and gnupg2 are installed
sudo apt update
sudo apt install -y curl gnupg2 apt-transport-https

# Add the new Plex GPG key
curl -L https://downloads.plex.tv/plex-keys/PlexSign.v2.key | sudo gpg --yes --dearmor -o /etc/apt/keyrings/plexmediaserver.v2.gpg

# Add the new repository to sources.list.d
echo "deb [signed-by=/etc/apt/keyrings/plexmediaserver.v2.gpg] https://repo.plex.tv/deb/ public main" | sudo tee /etc/apt/sources.list.d/plex.list

# Install Plex Media Server
sudo apt update
sudo apt install -y plexmediaserver
