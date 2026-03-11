#!/bin/bash

# Usage: ./sync.sh filelist.txt user@remotehost:/backup/path
# export SYNC_DRYRUN=1 to use dry run

set -euo pipefail

FILELIST="$1"
DESTINATION="$2"

if [[ ! -f "$FILELIST" ]]; then
    echo "Error: File list '$FILELIST' not found."
    exit 1
fi

echo "Starting backup using rsync..."
echo "Source list: $FILELIST"
echo "Destination: $DESTINATION"
echo

EXCL_FILE="$(mktemp)"
INCL_FILE="$(mktemp)"

while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    if [[ "$line" == \!* ]]; then
        echo "${line:1}" >> "$EXCL_FILE"
    else
        echo "$line" >> "$INCL_FILE"
    fi
done < "$FILELIST"

RSYNC_OPTS="-avh --recursive --progress"
if [[ "${SYNC_DRYRUN:-0}" == "1" ]]; then
    RSYNC_OPTS+=" --dry-run"
fi

rsync $RSYNC_OPTS --files-from=$INCL_FILE --exclude-from=$EXCL_FILE / "$DESTINATION"

echo "Backup completed successfully."
