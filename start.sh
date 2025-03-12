#!/bin/bash


# Start Server

java -Xmx4096M -Xms4096M -jar server.jar nogui


# Run Backup

bash /home/carlos/server/backup.sh

