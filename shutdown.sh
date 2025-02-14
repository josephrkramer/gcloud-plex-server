#!/bin/bash

ZONE=us-east1-b
INIT_DATE=$(date +%Y%m%d-%H%M%S)
SNAPSHOT_NAME=plex-snapshot-$INIT_DATE


gcloud config set project basic-lock-251300


gcloud auth login


# Get a list of VM instances with creation timestamps, sorted in descending order
instances=$(gcloud compute instances list \
            --format="value(name,creationTimestamp)" \
            --sort-by=~creationTimestamp)

# Extract the name of the most recent VM (the first line in the output)
most_recent_vm=$(echo "$instances" | head -n 1 | awk '{print $1}')

# Check if a VM was found
if [ -z "$most_recent_vm" ]; then
  echo "No VM instances found"
  exit 1
else
  echo "Most recent VM: $most_recent_vm"
fi

echo "Stopping instance $most_recent_vm"
gcloud compute instances stop $most_recent_vm --zone $ZONE

# Get a list of disks with creation timestamps, sorted in descending order
disks=$(gcloud compute disks list \
            --format="value(name,creationTimestamp)" \
            --sort-by=~creationTimestamp)

# Extract the name of the most recent VM (the first line in the output)
most_recent_disk=$(echo "$disks" | head -n 1 | awk '{print $1}')

# Check if a VM was found
if [ -z "$most_recent_disk" ]; then
  echo "No disks found"
  exit 1
else
  echo "Most recent disk: $most_recent_disk"
fi

#gcloud compute snapshots create snapshot-1 --project=basic-lock-251300 --source-disk=plex-server-20240218-181437 --source-disk-zone=us-east1-b --storage-location=us-east1
echo "Creating snapshot $SNAPSHOT_NAME from disk $most_recent_disk"
gcloud compute snapshots create $SNAPSHOT_NAME \
     --source-disk=$most_recent_disk \
     --source-disk-zone=$ZONE \
     --storage-location=us-east1

#-------------------------------------------

# Get a list of snapshots with creation timestamps, sorted in ascending order (oldest first)
snapshots=$(gcloud compute snapshots list \
            --format="value(name,creationTimestamp)" \
            --sort-by=creationTimestamp)

# Count the number of snapshots
snapshot_count=$(echo "$snapshots" | wc -l)
echo "Number of snapshots: $snapshot_count"

# Extract the name of the oldest snapshot (the first line in the output)
oldest_snapshot=$(echo "$snapshots" | head -n 1 | awk '{print $1}')

# Check if a snapshot was found
if [ -z "$oldest_snapshot" ]; then
  echo "No snapshots found, leaving VM instance in tact as a snapshot should have been created"
  exit 1
else
  echo "Oldest snapshot: $oldest_snapshot"
fi

#Delete the snapshot
if (( snapshot_count > 2 )); then
    echo "Found $snapshot_count snapshots, deleting the oldest snapshot: $oldest_snapshot"
    gcloud compute snapshots delete --quiet $oldest_snapshot
else
    echo "Only $snapshot_count snapshot(s), not deleting anything"
fi

#-------------------------------------------

#Delete the instance
gcloud compute instances delete --quiet $most_recent_vm --zone $ZONE

echo "Done. Plex server shutdown."

