#! /bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

if ! which anacron; then
    echo "anacron must be installed"
    exit 1
fi


read -p "how often to change the background? (minutes): " minutes
if ((60 % $minutes)) || [ 60 -le $minutes ]; then
    echo "minutes must be divisible by and less than 60"
    exit 1
fi

read -p "subreddit to get the images from, default 'wallpaper': " subreddit

if [ -z $subreddit ]; then
    echo "using default subreddit"
    subreddit='wallpaper'
else
    echo "Trusting that the $subreddit subreddit exists"
fi

mkdir -p /home/$SUDO_USER/Pictures/wallpaper /home/$SUDO_USER/Pictures/saved_wallpaper

echo "copying files to usr/local/bin"
cp wallpaperSwitcher wpdownload wprand /usr/local/bin 
cp anacrontab /etc/cron.daily

sed -ri "s/subreddit='wallpaper'/subreddit='$subreddit'/g" /usr/local/bin/wpdownload
sed -ri "s/user='username'/user='$SUDO_USER'/g" /usr/local/bin/wpdownload

echo "adding line to user $SUDO_USER crontab"
line="*/$minutes * * * * . wallpaperSwitcher"

if ! crontab -l -u $SUDO_USER | grep "wallpaperSwitcher" 
then    
    (crontab -u $SUDO_USER -l; echo "$line" ) | crontab -u $SUDO_USER -
else
    echo "wallpaperSwitcher already in crontab"
fi
