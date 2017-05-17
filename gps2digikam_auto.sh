#!/usr/bin/env bash
#
# gps2digikam_auto
# Version: 1.0
# By: AndriusWild
# Licence: GPLv3
#
#This script reads GPS coordinates of format A from video files, converts them to the format B readable by digiKam Geolocation Editor and returns the converted string to the clipboard.
#Format A: "+xx.xxxx-yyy.yyyy/" This format is how Samsung Galaxy S6 writes GPS coordinates to video files.
#Format B: "geo:xx.xxxxxxxxx,-yyy.yyyyyyyyy" This format is what digiKam accepts when pasting GPS coordinates in Geolocator Editor (Ctrl+Shift+G)
#
#Usage:
#
#Install xclip and mediainfo in your system
#Create gps2digikam_manual.desktop file as shown below, copy to $HOME/.local/share/applications and make executable
#
#[Desktop Entry]
#This script reads GPS coordinates of format A from video files, converts them to the format B readable by digiKam Geolocation Editor and returns the converted string to the clipboard
#Exec="/path/to/gps2digikam_auto.sh" %F
#GenericName=gps2digikam_auto
#Icon=gps
#MimeType=video/x-msvideo;video/quicktime;video/mpeg;video/mp4;
#Name=Copy GPS to clipboard
#Path=/path/to
#StartupNotify=true
#Terminal=false
#TerminalOptions=
#Type=Application
#X-DBUS-ServiceName=
#X-DBUS-StartupType=
#X-KDE-SubstituteUID=false
#X-KDE-Username=
#
#Select file in your file manager -> Right click -> Open With -> Copy GPS to clipboard
#Open digiKam -> Select the items you want to write the GPS coordinates to -> press Ctrl + Shift + G -> click on the file list at the botom of the Geolocator Editor window -> press Ctrl + A -> right click on selected files -> Paste coordinates -> Click "Apply"


for f in "$@"; do
mediainfo $f | grep "©xyz" | head -n 1 | while read -r clipboard_original; do
    latitude=${clipboard_original:43:8}
    longitude=${clipboard_original:51:9}
    clipboard_for_digikam_geo=""geo:""${latitude//+}"00000,"${longitude//+}"00000"
    echo "$clipboard_for_digikam_geo" | xclip -selection c
    done
done
exit
