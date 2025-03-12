#!/bin/bash


# Iniciar el servidor de Minecraft

java -Xmx4096M -Xms4096M -jar server.jar nogui


# Después de que el servidor se cierre, ejecutar la copia de seguridad

bash /home/carlos/server/backup.sh

