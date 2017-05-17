#!/usr/bin/env bash
#
# gps2digikam_manual
# Version: 1.0
# By: AndriusWild
# Licence: GPLv3
#
#This script gets GPS coordinates of the format A from the clipboard, converts them to the format B and returns the converted string back to the clipboard.
#Format A: "+xx.xxxx-yyy.yyyy/" This format is how Samsung Galaxy S6 writes GPS coordinates to video files.
#Format B: "geo:xx.xxxxxxxxx,-yyy.yyyyyyyyy" This format is what digiKam accepts when pasting GPS coordinates in Geolocator Editor (Ctrl+Shift+G)
#
#Usage:
#
#Install xclip and mediainfo in your system
#Create gps2digikam_manual.desktop file as shown below and make executable
#
#[Desktop Entry]
#Comment=This script gets GPS coordinates of the format A from the clipboard, converts them to the format B and returns the converted string back to the clipboard
#Exec=/path/to/gps2digikam_manual.sh
#GenericName=gps2digikam_manual
#Icon=gps
#MimeType=video/x-msvideo;video/quicktime;video/mpeg;video/mp4;
#Name=gps2digikam_manual
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
#Select file in your file manager -> Right click -> Open With -> MediaInfo -> View -> Text-> Select "+xx.xxxx-yyy.yyyy/" value beside "©xyz" -> Ctrl + C (copy to clipboard)
#Double click gps2digikam_manual.desktop or Press Alt +F2 -> start typing "gps2..." -> click on gps2digikam_manual.desktop
#Open digiKam -> Select the items you want to write the GPS coordinates to -> press Ctrl + Shift + G -> click on the file list at the botom of the Geolocator Editor window -> press Ctrl + A -> right click on selected files -> Paste coordinates -> Click "Apply"

clipboard_original="$(xclip -o)"
latitude=${clipboard_original:0:8}
longitude=${clipboard_original:8:9}
clipboard_for_digikam_geo=""geo:""${latitude//+}"00000,"${longitude//+}"00000"
echo "$clipboard_for_digikam_geo" | xclip -selection c
exit
