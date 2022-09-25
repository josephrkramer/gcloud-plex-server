#!/bin/bash

sudo apt install curl
curl https://downloads.plex.tv/plex-keys/PlexSign.key | sudo apt-key add -

echo deb https://downloads.plex.tv/repo/deb ./public main | sudo tee /etc/apt/sources.list.d/plexmediaserver.list

sudo apt install apt-transport-https
sudo apt update
sudo apt install plexmediaserver
