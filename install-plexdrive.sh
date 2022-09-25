#!/bin/bash

wget https://github.com/plexdrive/plexdrive/releases/latest/download/plexdrive-linux-amd64 && chmod +x plexdrive-linux-amd64 && sudo mv plexdrive-linux-amd64 /usr/bin/plexdrive && sudo cp plexdrive.service /etc/systemd/system/plexdrive.service && sudo plexdrive mount -c /root/.plexdrive -o allow_other /mnt/plexdrive
