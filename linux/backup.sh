#!/bin/bash

hostname=`hostname`

/extstor/scripts/sync.sh /extstor/scripts/sync-filelist.txt me@nasserver.lan:/mnt/Backups/$hostname/
