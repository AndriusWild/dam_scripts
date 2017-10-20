#!/usr/bin/env bash

for f in "$@"; do
dbus-send --session --type=method_call    --dest="org.freedesktop.FileManager1"     "/org/freedesktop/FileManager1"     "org.freedesktop.FileManager1.ShowItems" array:string:"file:"${f}""     string:""
done
exit
