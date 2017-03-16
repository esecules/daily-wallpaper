#! /bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

read -p "how often to change the background? (minutes): " minutes

if ((60 % $minutes)) || [ 60 -le $minutes ]; then
    echo "minutes must be divisible by and less than 60"
    exit 1
fi

echo "copying files to usr/local/bin"
cp wallpaperSwitcher wpdownload wprand /usr/local/bin 

echo "adding line to user $SUDO_USER crontab"
line="*/$minutes * * * * . wallpaperSwitcher"

if ! crontab -l -u $SUDO_USER | grep "wallpaperSwitcher" 
then    
    (crontab -u $SUDO_USER -l; echo "$line" ) | crontab -u $SUDO_USER -
else
    echo "wallpaperSwitcher already in crontab"
fi
