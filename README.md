# MCServerTools - Script de Copia de Seguridad para Minecraft

🏰️ **MCServerTools** es un script en Bash para realizar copias de seguridad automáticas de un mundo de Minecraft dentro de un servidor.

📂 Guarda copias del mundo, detecta eliminaciones manuales y borra copias antiguas de forma automática.

## 🚀 Características

✅ **Copias de seguridad organizadas** con fecha y hora en el nombre.  
✅ **Registra en un log (`backup.log`)** todas las acciones: backups, eliminaciones manuales y automáticas.  
✅ **Elimina automáticamente** backups más antiguos de 7 días.  
✅ **Detecta eliminaciones manuales** y las registra en el log.  
✅ **Interfaz interactiva** con confirmación antes de hacer un backup.  

## 🛠️ Instalación y Uso

1️⃣ **Clonar el repositorio:**  
```bash
git clone https://github.com/idarkcharly/MCServerTools.git
cd MCServerTools
```
2️⃣ **Mover Scripts a la carpeta del servidor**
```bash
mv start.sh backup.sh restore.sh /home/tuusuario/server
```
3️⃣ **Dar permisos de ejecución al script:**  
```bash
sudo chown -R tuusuario:tuusuario ~/server
chmod +x backup.sh start.sh restore.sh
```

4️⃣ **Dar inicio al servidor:**  
```bash
./start.sh
```

## 📂 Ubicación de archivos

- 📌 **Mundo de Minecraft:** `/home/tuusuario/server/world`
- 📌 **Backups guardados en:** `/home/tuusuario/backup`  
- 📌 **Log de acciones:** `/home/tuusuario/backup/logs/backup.log`  

## 🐧 Licencia
Este script es de uso libre. Si lo mejoras, ¡haz un pull!   
