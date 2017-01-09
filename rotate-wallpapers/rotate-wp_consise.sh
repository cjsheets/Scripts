#!/bin/bash

DIR="/mnt/hdd_snapraid/Images/Wallpaper/1920x1200/"
RECURSIVE=false

MONITORS=(
  "/backdrop/screen0/monitor0/workspace0/last-image"
  "/backdrop/screen0/monitor1/workspace0/last-image"
  "/backdrop/screen0/monitor2/workspace0/last-image")

[ `ps aux | grep --count "[r]otateWallpapers.sh"` -gt 2 ] && exit 1;

WAIT_UNTIL_IDLE=true
IDLE_TIME=5
SLEEP_TIME=20
GET_IDLE="/home/chad/EncFS/Scripts/getIdle"

PID=$(pgrep xfce4-session)
export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$PID/environ|cut -d= -f2-)
export DISPLAY=:0.0

if [ "$WAIT_UNTIL_IDLE" = true ]; then
  while true; do
    idleTime=$($GET_IDLE)
    if [[ $idleTime -gt $( printf %0.f $(echo "$IDLE_TIME * 1000  * 60" | bc -l)) ]] ; then
      break;
    fi
    sleep $SLEEP_TIME
  done
fi

for MONITOR in "${MONITORS[@]}"; do
  if [ "$RECURSIVE" = true ]; then
    WALLPAPER=$(find $DIR -type f | shuf -n1)
  else
    WALLPAPER=$(find $DIR -maxdepth 1 -type f | shuf -n1)
  fi
  /usr/bin/xfconf-query -c xfce4-desktop -p $MONITOR -s $WALLPAPER;
done