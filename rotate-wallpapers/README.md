# Rotate Wallpapers

This script allows XFCE based desktops to rotate wallpapers at a defined interval and only when the workstation is idle.

# Settings

The following settings are availble:

* `DIR="/mnt/..../1920x1200/"`
  - directory containing wallpapers
* `RECURSIVE=false`
  - Should wallpaper sub-directories be rotated through as well
* `MONITORS=("/backdrop/screen0/.../last-image" "/backdrop/screen0/.../last-image")`
  - xfconf settings paths for monitor wallpapers 
* `WAIT_UNTIL_IDLE=true`
  - should the wallpapers only change when system is idle
* `IDLE_TIME=5`
  - time (in minutes) computer must be idle to change wallpaper
* `SLEEP_TIME=20`
  - time (in seconds) to wait in between 'idle' polls 
* `GET_IDLE="/home/.../getIdle"`
  - path to tiny C program that reports system idle time
  - self-compile the included source with: `gcc -o getIdle getIdle.c -lXss -lX11`


# Determine Monitor Paths

In order to use the script you need to determine the setting path for each of your monitors.

The following command lists each setting option along with its current value.

  /usr/bin/xfconf-query -c xfce4-desktop -l -v

One technique for determining the correct path is to run the following command to monitor the settings, then manually change your wallpaper. The needed paths will display on the command line.

  /usr/bin/xfconf-query -c xfce4-desktop -m

## Cron

This script is intended to run with user permissions. I recommend setting `SHELL=/bin/bash` at the top of your users crontab entry (`crontab -u cjsheets -e`).

I rotate wallappers every 6 hours.

  0 */6 * * * /.../rotateWallpapers.sh