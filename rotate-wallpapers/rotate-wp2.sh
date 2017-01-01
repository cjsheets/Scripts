#!/bin/bash

#/usr/bin/xfconf-query -c xfce4-desktop -l -v

# crontab -u chad -e
# SHELL=/bin/bash
# 0 */6 * * * /home/chad/EncFS/Scripts/rotateWallpapers.sh

echo "launched" >> /home/chad/Desktop/out.log
echo $(ps aux | grep "[r]otateWallpapers.sh") >> /home/chad/Desktop/out.log
DIR="/mnt/hdd_snapraid/Images/Wallpaper/1920x1200/"
RECURSIVE=false

MONITORS=(
  "/backdrop/screen0/monitor0/workspace0/last-image"
  "/backdrop/screen0/monitor1/workspace0/last-image"
  "/backdrop/screen0/monitor2/workspace0/last-image")

WAIT_UNTIL_IDLE=true
IDLE_TIME=10
GET_IDLE="/home/chad/EncFS/Scripts/getIdle"
echo "setttings done" >> /home/chad/Desktop/out.log
[ `ps aux | grep --count "[r]otateWallpapers.sh"` -gt 2 ] && exit 1;
echo "not running" >> /home/chad/Desktop/out.log

#PID=$(pgrep gnome-session)
PID=$(pgrep xfce4-session)
export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$PID/environ|cut -d= -f2-)

echo "session ID" >> /home/chad/Desktop/out.log
echo "$DBUS_SESSION_BUS_ADDRESS" >> /home/chad/Desktop/out.log
if [ "$WAIT_UNTIL_IDLE" = true ]; then
  while true; do
    idleTime=$($GET_IDLE)
    echo "idle time:" >> /home/chad/Desktop/out.log
    echo $($GET_IDLE) >> /home/chad/Desktop/out.log
    if [[ $idleTime -gt $(($IDLE_TIME * 1000 * 60)) ]] ; then
    echo "done idling" >> /home/chad/Desktop/out.log
      break;
    fi
    echo "sleep" >> /home/chad/Desktop/out.log
    sleep 30
  done
fi

echo "change wallpaper" >> /home/chad/Desktop/out.log

for MONITOR in "${MONITORS[@]}"; do
  if [ "$RECURSIVE" = true ]; then
    WALLPAPER=$(find $DIR -type f | shuf -n1)
  else
    WALLPAPER=$(find $DIR -maxdepth 1 -type f | shuf -n1)
  fi
  /usr/bin/xfconf-query -c xfce4-desktop -p $MONITOR -s $WALLPAPER;
  echo $WALLPAPER;
done
