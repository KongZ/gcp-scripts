#!/bin/bash
# Original idea from "Alan Fuller, Fullworks"
#
# Loop through all disks within this project  and create a snapshot
#
gcloud compute disks list --format='value(name,zone)'| while read DISK_NAME ZONE; do
  gcloud compute disks snapshot $DISK_NAME --snapshot-names autogcs-${DISK_NAME:0:31}-$(date "+%Y-%m-%d-%s") --zone $ZONE
done
#
# Snapshots are incremental and dont need to be deleted, deleting snapshots will merge snapshots, so deleting doesn't loose anything
# having too many snapshots is unwiedly so this script deletes them after 60 days
#
if [[ $(uname) == "Linux" ]]; then
  from_date=$(date -d "-30 days" "+%Y-%m-%d")
else
  from_date=$(date -v -30d "+%Y-%m-%d")
fi
gcloud compute snapshots list --filter="creationTimestamp<$from_date AND name~'(autogcs.*)'" --uri | while read SNAPSHOT_URI; do
  gcloud compute snapshots delete --quiet $SNAPSHOT_URI
done
