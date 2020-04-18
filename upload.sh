#!/bin/sh
PATH=/Users/mac/Desktop/DEV/Gozer/riplay-rp
HOST='cpu-linux.riplay.fr'
USER='gozer'
PASSWORD='aiZnr9UZnrSNf81_4'
DIRECTORY='/Users/mac/Desktop/DEV/Gozer/riplay-rp/compiled/*'

echo "Upload on Linux Server"
$PATH/ncftpput -R -u $USER -p $PASSWORD $HOST /serveurs/roleplay_linux/csgo/addons/sourcemod/plugins/roleplay $DIRECTORY
echo "Upload on Linux Server ended"

echo "Upload on Windows Server"
$PATH/ncftpput -R -u $USER -p $PASSWORD $HOST /serveurs/roleplay_windows/csgo/addons/sourcemod/plugins/roleplay $DIRECTORY
echo "Upload on Windows Server"