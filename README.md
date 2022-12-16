# gcloud-plex-server
Scripts to automate creation of a Plex Server on Google Compute Engine

From https://github.com/plexdrive/plexdrive -- OBSOLETE
- Link to latest plexdrive asset https://github.com/plexdrive/plexdrive/releases/latest/download/plexdrive-linux-amd64

Install and configure rclone for filesystem access

```
sudo apt-get install rclone
rclone config
```

Install guides to use as templates for later automation:
- https://www.linuxbabe.com/ubuntu/install-plex-media-server-ubuntu-18-04
- https://linuxize.com/post/how-to-install-plex-media-server-on-debian-9/
- https://www.cyberciti.biz/faq/how-to-set-up-automatic-updates-for-ubuntu-linux-18-04/

Backup instructions for later automation:
- https://support.plex.tv/articles/201539237-backing-up-plex-media-server-data/

Remote desktop auto-install instructions:
- https://cloud.google.com/architecture/chrome-desktop-remote-on-compute-engine
- Monitor gcloud-startup-script.sh install progress
```
sudo journalctl -o cat -f _SYSTEMD_UNIT=google-startup-scripts.service
```
- Set a password
```
sudo passwd $(whoami)
```
- Add user to sudoers
```
sudo adduser $(whoami) sudo
```
- https://remotedesktop.google.com/headless

Configure plex from remote desktop machine:
- http://127.0.0.1:32400/web
