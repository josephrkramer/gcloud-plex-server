#!/bin/bash
#gcloud compute instances create plex-template-20240218-173331 --project=basic-lock-251300 --zone=us-east1-b --machine-type=e2-standard-4 --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default --metadata=startup-script=\#\!/bin/bash\ -x$'\n'\#$'\n'\#\ Startup\ script\ to\ install\ Chrome\ remote\ desktop\ and\ a\ desktop\ environment.$'\n'\#$'\n'\#\ See\ environmental\ variables\ at\ then\ end\ of\ the\ script\ for\ configuration$'\n'\#$'\n'$'\n'function\ install_desktop_env\ \{$'\n'\ \ PACKAGES=\"desktop-base\ xscreensaver\ dbus-x11\"$'\n'$'\n'\ \ if\ \[\[\ \"\$INSTALL_XFCE\"\ \!=\ \"yes\"\ \&\&\ \"\$INSTALL_CINNAMON\"\ \!=\ \"yes\"\ \]\]\ \;\ then$'\n'\ \ \ \ \#\ neither\ XFCE\ nor\ cinnamon\ specified\;\ install\ both$'\n'\ \ \ \ INSTALL_XFCE=yes$'\n'\ \ \ \ INSTALL_CINNAMON=yes$'\n'\ \ fi$'\n'$'\n'\ \ if\ \[\[\ \"\$INSTALL_XFCE\"\ =\ \"yes\"\ \]\]\ \;\ then$'\n'\ \ \ \ PACKAGES=\"\$PACKAGES\ xfce4\"$'\n'\ \ \ \ echo\ \"exec\ xfce4-session\"\ \>\ /etc/chrome-remote-desktop-session$'\n'\ \ \ \ \[\[\ \"\$INSTALL_FULL_DESKTOP\"\ =\ \"yes\"\ \]\]\ \&\&\ \\$'\n'\ \ \ \ \ \ PACKAGES=\"\$PACKAGES\ task-xfce-desktop\"$'\n'\ \ fi$'\n'$'\n'\ \ if\ \[\[\ \"\$INSTALL_CINNAMON\"\ =\ \"yes\"\ \]\]\ \;\ then$'\n'\ \ \ \ PACKAGES=\"\$PACKAGES\ cinnamon-core\"$'\n'\ \ \ \ echo\ \"exec\ cinnamon-session-cinnamon2d\"\ \>\ /etc/chrome-remote-desktop-session$'\n'\ \ \ \ \[\[\ \"\$INSTALL_FULL_DESKTOP\"\ =\ \"yes\"\ \]\]\ \&\&\ \\$'\n'\ \ \ \ \ \ PACKAGES=\"\$PACKAGES\ task-cinnamon-desktop\"$'\n'\ \ fi$'\n'$'\n'\ \ DEBIAN_FRONTEND=noninteractive\ \\$'\n'\ \ \ \ apt-get\ install\ --assume-yes\ \$PACKAGES\ \$EXTRA_PACKAGES$'\n'$'\n'\ \ systemctl\ disable\ lightdm.service$'\n'\}$'\n'$'\n'function\ download_and_install\ \{\ \#\ args\ URL\ FILENAME$'\n'\ \ curl\ -L\ -o\ \"\$2\"\ \"\$1\"$'\n'\ \ dpkg\ --install\ \"\$2\"$'\n'\ \ apt-get\ install\ --assume-yes\ --fix-broken$'\n'\}$'\n'$'\n'function\ is_installed\ \{\ \ \#\ args\ PACKAGE_NAME$'\n'\ \ dpkg-query\ --list\ \"\$1\"\ \|\ grep\ -q\ \"^ii\"\ 2\>/dev/null$'\n'\ \ return\ \$\?$'\n'\}$'\n'$'\n'\#\ Configure\ the\ following\ environmental\ variables\ as\ required:$'\n'INSTALL_XFCE=yes$'\n'INSTALL_CINNAMON=no$'\n'INSTALL_CHROME=yes$'\n'INSTALL_FULL_DESKTOP=no$'\n'$'\n'\#\ Any\ additional\ packages\ that\ should\ be\ installed\ on\ startup\ can\ be\ added\ here$'\n'EXTRA_PACKAGES=\"less\ bzip2\ zip\ unzip\ tasksel\ wget\ git\ xfce4-terminal\"$'\n'$'\n'apt-get\ update$'\n'apt-get\ upgrade\ --assume-yes\ --fix-broken\ --with-new-pkgs$'\n'$'\n'\#\ Install\ backports\ version\ of\ libgbm1\ on\ Debian\ 9/stretch$'\n'\[\[\ \$\(/usr/bin/lsb_release\ --codename\ --short\)\ ==\ \"stretch\"\ \]\]\ \&\&\ \\$'\n'\ \ apt-get\ install\ --assume-yes\ libgbm1/stretch-backports$'\n'$'\n'\!\ is_installed\ chrome-remote-desktop\ \&\&\ \\$'\n'\ \ download_and_install\ \\$'\n'\ \ \ \ https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb\ \\$'\n'\ \ \ \ /tmp/chrome-remote-desktop_current_amd64.deb$'\n'$'\n'install_desktop_env$'\n'$'\n'\[\[\ \"\$INSTALL_CHROME\"\ =\ \"yes\"\ \]\]\ \&\&\ \\$'\n'\ \ \!\ is_installed\ google-chrome-stable\ \&\&\ \\$'\n'\ \ download_and_install\ \\$'\n'\ \ \ \ https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb\ \\$'\n'\ \ \ \ /tmp/google-chrome-stable_current_amd64.deb$'\n'$'\n'echo\ \"Chrome\ remote\ desktop\ installation\ completed\" --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=453460631559-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \--create-disk=auto-delete=yes,boot=yes,device-name=plex-template-1,mode=rw,size=60,source-snapshot=https://www.googleapis.com/compute/v1/projects/basic-lock-251300/global/snapshots/plex-snapshot-20240215,type=projects/basic-lock-251300/zones/us-east1-b/diskTypes/pd-balanced --labels=goog-ec-src=vm_add-gcloud --reservation-affinity=any

#gcloud compute instances create plex-template-20240218-173331 --project=basic-lock-251300 --zone=us-east1-b

ZONE=us-east1-b
TEMPLATE=plex-template-1
INIT_DATE=$(date +%Y%m%d-%H%M%S)
DISK_NAME=plex-disk-$INIT_DATE
SERVER_NAME=plex-server-$INIT_DATE

# Get a list of snapshots, along with their creation timestamps, sorted in descending order 
snapshots=$(gcloud compute snapshots list \
            --format="value(name,creationTimestamp)" \
            --sort-by=~creationTimestamp)

# Extract the name of the most recent snapshot (the first line in the output)
most_recent_snapshot=$(echo "$snapshots" | head -n 1 | awk '{print $1}')

# Check if a snapshot was found
if [ -z "$most_recent_snapshot" ]; then
  echo "No snapshots found"
  exit 1
else
  echo "Most recent snapshot: $most_recent_snapshot"
fi

#gcloud compute instances create $SERVER_NAME --project=basic-lock-251300 --zone=$ZONE --machine-type=e2-standard-4 --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default --metadata=startup-script=\#\!/bin/bash\ -x$'\n'\#$'\n'\#\ Startup\ script\ to\ install\ Chrome\ remote\ desktop\ and\ a\ desktop\ environment.$'\n'\#$'\n'\#\ See\ environmental\ variables\ at\ then\ end\ of\ the\ script\ for\ configuration$'\n'\#$'\n'$'\n'function\ install_desktop_env\ \{$'\n'\ \ PACKAGES=\"desktop-base\ xscreensaver\ dbus-x11\"$'\n'$'\n'\ \ if\ \[\[\ \"\$INSTALL_XFCE\"\ \!=\ \"yes\"\ \&\&\ \"\$INSTALL_CINNAMON\"\ \!=\ \"yes\"\ \]\]\ \;\ then$'\n'\ \ \ \ \#\ neither\ XFCE\ nor\ cinnamon\ specified\;\ install\ both$'\n'\ \ \ \ INSTALL_XFCE=yes$'\n'\ \ \ \ INSTALL_CINNAMON=yes$'\n'\ \ fi$'\n'$'\n'\ \ if\ \[\[\ \"\$INSTALL_XFCE\"\ =\ \"yes\"\ \]\]\ \;\ then$'\n'\ \ \ \ PACKAGES=\"\$PACKAGES\ xfce4\"$'\n'\ \ \ \ echo\ \"exec\ xfce4-session\"\ \>\ /etc/chrome-remote-desktop-session$'\n'\ \ \ \ \[\[\ \"\$INSTALL_FULL_DESKTOP\"\ =\ \"yes\"\ \]\]\ \&\&\ \\$'\n'\ \ \ \ \ \ PACKAGES=\"\$PACKAGES\ task-xfce-desktop\"$'\n'\ \ fi$'\n'$'\n'\ \ if\ \[\[\ \"\$INSTALL_CINNAMON\"\ =\ \"yes\"\ \]\]\ \;\ then$'\n'\ \ \ \ PACKAGES=\"\$PACKAGES\ cinnamon-core\"$'\n'\ \ \ \ echo\ \"exec\ cinnamon-session-cinnamon2d\"\ \>\ /etc/chrome-remote-desktop-session$'\n'\ \ \ \ \[\[\ \"\$INSTALL_FULL_DESKTOP\"\ =\ \"yes\"\ \]\]\ \&\&\ \\$'\n'\ \ \ \ \ \ PACKAGES=\"\$PACKAGES\ task-cinnamon-desktop\"$'\n'\ \ fi$'\n'$'\n'\ \ DEBIAN_FRONTEND=noninteractive\ \\$'\n'\ \ \ \ apt-get\ install\ --assume-yes\ \$PACKAGES\ \$EXTRA_PACKAGES$'\n'$'\n'\ \ systemctl\ disable\ lightdm.service$'\n'\}$'\n'$'\n'function\ download_and_install\ \{\ \#\ args\ URL\ FILENAME$'\n'\ \ curl\ -L\ -o\ \"\$2\"\ \"\$1\"$'\n'\ \ dpkg\ --install\ \"\$2\"$'\n'\ \ apt-get\ install\ --assume-yes\ --fix-broken$'\n'\}$'\n'$'\n'function\ is_installed\ \{\ \ \#\ args\ PACKAGE_NAME$'\n'\ \ dpkg-query\ --list\ \"\$1\"\ \|\ grep\ -q\ \"^ii\"\ 2\>/dev/null$'\n'\ \ return\ \$\?$'\n'\}$'\n'$'\n'\#\ Configure\ the\ following\ environmental\ variables\ as\ required:$'\n'INSTALL_XFCE=yes$'\n'INSTALL_CINNAMON=no$'\n'INSTALL_CHROME=yes$'\n'INSTALL_FULL_DESKTOP=no$'\n'$'\n'\#\ Any\ additional\ packages\ that\ should\ be\ installed\ on\ startup\ can\ be\ added\ here$'\n'EXTRA_PACKAGES=\"less\ bzip2\ zip\ unzip\ tasksel\ wget\ git\ xfce4-terminal\"$'\n'$'\n'apt-get\ update$'\n'apt-get\ upgrade\ --assume-yes\ --fix-broken\ --with-new-pkgs$'\n'$'\n'\#\ Install\ backports\ version\ of\ libgbm1\ on\ Debian\ 9/stretch$'\n'\[\[\ \$\(/usr/bin/lsb_release\ --codename\ --short\)\ ==\ \"stretch\"\ \]\]\ \&\&\ \\$'\n'\ \ apt-get\ install\ --assume-yes\ libgbm1/stretch-backports$'\n'$'\n'\!\ is_installed\ chrome-remote-desktop\ \&\&\ \\$'\n'\ \ download_and_install\ \\$'\n'\ \ \ \ https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb\ \\$'\n'\ \ \ \ /tmp/chrome-remote-desktop_current_amd64.deb$'\n'$'\n'install_desktop_env$'\n'$'\n'\[\[\ \"\$INSTALL_CHROME\"\ =\ \"yes\"\ \]\]\ \&\&\ \\$'\n'\ \ \!\ is_installed\ google-chrome-stable\ \&\&\ \\$'\n'\ \ download_and_install\ \\$'\n'\ \ \ \ https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb\ \\$'\n'\ \ \ \ /tmp/google-chrome-stable_current_amd64.deb$'\n'$'\n'echo\ \"Chrome\ remote\ desktop\ installation\ completed\" --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=453460631559-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
#--create-disk=auto-delete=yes,boot=yes,device-name=$DISK_NAME,mode=rw,size=60,source-snapshot=$most_recent_snapshot,type=projects/basic-lock-251300/zones/us-east1-b/diskTypes/pd-balanced --labels=goog-ec-src=vm_add-gcloud --reservation-affinity=any

#echo "Done. Plex server ready."
#exit 0

#create disk from snapshot
#echo "Creating disk $DISK_NAME from $most_recent_snapshot"
gcloud compute disks create $DISK_NAME \
    --source-snapshot=$most_recent_snapshot \
    --zone=$ZONE

#create instance using template and disk
#echo "Creating instance $SERVER_NAME from $DISK_NAME"
gcloud compute instances create $SERVER_NAME \
  --zone=$ZONE \
  --source-instance-template=$TEMPLATE \
  --disk=name=$DISK_NAME,boot=yes,auto-delete=yes

echo "Done. Plex server ready."

