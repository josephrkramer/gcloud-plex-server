#!/bin/bash

# Get a list of snapshots with creation timestamps, sorted in ascending order (oldest first)
snapshots=$(gcloud compute snapshots list \
            --format="value(name,creationTimestamp)" \
            --sort-by=creationTimestamp)

#Print all snapshots
echo "SNAPSHOTS: $snapshots"

# Count the number of snapshots
snapshot_count=$(echo "$snapshots" | wc -l)
echo "Number of snapshots: $snapshot_count"

# Extract the name of the oldest snapshot (the first line in the output)
oldest_snapshot=$(echo "$snapshots" | head -n 1 | awk '{print $1}')

# Check if a snapshot was found
if [ -z "$oldest_snapshot" ]; then
  echo "No snapshots found"
else
  echo "Oldest snapshot: $oldest_snapshot"
fi
