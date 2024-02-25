#!/bin/bash

ZONE=us-east1-b
TEMPLATE=plex-template-1
INIT_DATE=$(date +%Y%m%d-%H%M%S)
DISK_NAME=plex-disk-$INIT_DATE
SERVER_NAME=plex-server-$INIT_DATE


gcloud config set project basic-lock-251300


gcloud auth login


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

#create disk from snapshot
echo "Creating disk $DISK_NAME from $most_recent_snapshot"
gcloud compute disks create $DISK_NAME \
    --source-snapshot=$most_recent_snapshot \
    --zone=$ZONE

#create instance using template and disk
echo "Creating instance $SERVER_NAME from $DISK_NAME"
gcloud compute instances create $SERVER_NAME \
  --zone=$ZONE \
  --source-instance-template=$TEMPLATE \
  --disk=name=$DISK_NAME,boot=yes,auto-delete=yes

echo "Done. Plex server ready."

