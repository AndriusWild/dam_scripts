#!/usr/bin/env bash
# -------------------------------------------------------------------------------------------------------------------------------------
# compress2mp4
# Version: 1.2
# By: AndriusWild
# Licence: GPLv3
# -------------------------------------------------------------------------------------------------------------------------------------
# This bash script compresses the specified video files (wildcards supported) to lossy h.264 format in an MP4 container.
#
# Usage:
# compress2mp4 <video/files/with/path.ext>
#
# Examples:
# /home/user/scripts/compress2mp4.sh /home/user/videos/foo.avi
# /home/user/scripts/compress2mp4.sh /home/user/videos/*.avi
# /home/user/scripts/compress2mp4.sh /home/user/videos/*
#
# You can also create a .desktop file as shown below, select multiple files in your file manager and open them with this script.
# Place the .desktop file in $HOME/.local/share/applications/ folder.
# Linux Mint MATE 18.2 users might need to install xterm and gnome-terminal in order to make the shortcut work.
#
#[Desktop Entry]
#Type=Application
#Categories=AudioVideo;Video;
#MimeType=video/x-msvideo;video/quicktime;video/mpeg;video/mp4;
#Name=Compress to mp4
#GenericName=Batch compress to mp4
#Comment=This bash script compresses the specified video files to lossy h.264 format in an MP4 container
#Exec=path/to/compress2mp4.sh %F
#Icon=video-mp4 #This works in OpenSUSE KDE. You might need to change the path depending on the OS you are at, e.g. here is what I have used on Linux Mint MATE: "application-vnd.rn-realmedia"
#Terminal=true


# 1. FFmpeg parameters

cv="libx264"
crf="23"
preset="slow"
ca="libfdk_aac"
ba="192k"
loglevel="warning" #switch loglevel to "info" if you want to see informative messages during processing (default mode)

# 2.1 Suffixes to be added to filenames
suffix="${cv//lib/}"
suffix2="gps" #this one is temporary

# 2.2 Path to the folder to store originals. Please change to the location of your choice.

store_originals_folder="/mnt/data/Video_files_originals"

# 3. Path to Bento4 SDK
# If you compiled Bento4 SDK from sources you should skip this step and use "mp4extract" and "mp4edit" straight
# If you downloaded binaries please make sure to mark mp4extract and mp4edit files as executable as well as change the path below

mp4extract="/home/andrey/Programs/Bento4-SDK-1-5-0-614/bin/mp4extract"
mp4edit="/home/andrey/Programs/Bento4-SDK-1-5-0-614/bin/mp4edit"

# 4. Creating folder to store originals

mkdir -p "${store_originals_folder}"

# Do not edit below this line.

# 5. Formatting
RED='\033[0;31m'
BLUE='\033[1;34m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
NC='\033[0m' # No formatting

# 6. Keep junk files in /tmp

pushd /tmp || exit 1

# 7. Test input files for validity, abort if invalid.

for f in "$@"; do
    ffprobe -v error "${f}" 1>/dev/null
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}The file is invalid: ${UNDERLINE} "${f##*/}" ${NC}"
        echo -e "${RED}Aborting.${NC}"
        exit 1
    fi
done

# 8. Compressing selected video files using ffmpeg

count="1"
for f in "$@"; do
    echo -e "${GREEN}Compressing file ${count}/${#@} ${UNDERLINE}"${f##*/}"${NC}"
    echo -e "${BLUE}ffmpeg -hide_banner -loglevel "${loglevel}" -y -i ${UNDERLINE}"${f##*/}"${NC} ${BLUE} -f mp4 -c:a "${ca}" -b:a "${ba}" -c:v "${cv}" -crf "${crf}" -preset "${preset}" -map_metadata 0 ${UNDERLINE}"$(basename "${f%.*}_${suffix}.mp4")"${NC}"
    ffmpeg -hide_banner -loglevel "${loglevel}" -y -i "${f}" -f mp4 -c:a "${ca}" -b:a "${ba}" -c:v "${cv}" -crf "${crf}" -preset "${preset}" -map_metadata 0 "${f%.*}_${suffix}.mp4" || exit 1
    ((count++))
done

# 9. Checking compression ratio

count="1"
for f in "$@"; do
    filesize_compressed=$(stat --format=%s "${f%.*}_${suffix}.mp4")
    filesize_original=$(stat --format=%s "${f%.*}.mp4")
    filesize_compressed_mb=$(echo "scale=2; ${filesize_compressed} / 1024 / 1024" | bc)
    filesize_original_mb=$(echo "scale=2; ${filesize_original} / 1024 / 1024" | bc)
    echo -e "${GREEN}Compressed file size: ${count}/${#@} ${UNDERLINE}"$(basename "${f%.*}_${suffix}.mp4")"${NC} ${GREEN} ${filesize_compressed_mb} MB ${NC}"
    echo -e "${GREEN}Original file size: ${count}/${#@} ${UNDERLINE}"$(basename "${f%.*}.mp4")"${NC} ${GREEN} ${filesize_original_mb} MB ${NC}"
    compression_ratio=$(echo "scale=2; ${filesize_original} / ${filesize_compressed}" | bc)
    echo -e "${GREEN}${BOLD}Compression ratio: ${compression_ratio} ${NC}"
#Uncomment the two lines below if you deleted block # 10
#   ((count++))
#done

# 10. Recompressing files with ratio < 1.5

    if (( $(echo "${compression_ratio} < 1.5" | bc) )); then
        echo -e "${ORANGE}Deleting file: ${count}/${#@} ${UNDERLINE} "${f%.*}_${suffix}.mp4"${NC}"
        rm -f "${f%.*}_${suffix}.mp4"
        echo -e "${GREEN}Recompressing with CRF: $((${crf}+3)) ${NC}"
        echo -e "${BLUE}ffmpeg -hide_banner -loglevel "${loglevel}" -y -i ${UNDERLINE}"${f##*/}"${NC} ${BLUE} -f mp4 -c:a "${ca}" -b:a "${ba}" -c:v "${cv}" -crf $((${crf}+3)) -preset "${preset}" -map_metadata 0 ${UNDERLINE}"$(basename "${f%.*}_${suffix}.mp4")"${NC}"
        ffmpeg -hide_banner -loglevel "${loglevel}" -y -i "${f}" -f mp4 -c:a "${ca}" -b:a "${ba}" -c:v "${cv}" -crf $((${crf}+3)) -preset "${preset}" -map_metadata 0 "${f%.*}_${suffix}.mp4" || exit 1
        filesize_recompressed=$(stat --format=%s "${f%.*}_${suffix}.mp4")
        filesize_original=$(stat --format=%s "${f%.*}.mp4")
        filesize_recompressed_mb=$(echo "scale=2; ${filesize_recompressed} / 1024 / 1024" | bc)
        filesize_original_mb=$(echo "scale=2; ${filesize_original} / 1024 / 1024" | bc)
        echo -e "${GREEN}Recompressed file size: ${count}/${#@} ${UNDERLINE}"$(basename "${f%.*}_${suffix}.mp4")"${NC} ${GREEN} ${filesize_recompressed_mb} MB ${NC}"
        echo -e "${GREEN}Original file size: ${count}/${#@} ${UNDERLINE}"$(basename "${f%.*}.mp4")"${NC} ${GREEN} ${filesize_original_mb} MB ${NC}"
        recompression_ratio=$(echo "scale=2; ${filesize_original} / ${filesize_recompressed}" | bc)
        echo -e "${GREEN}${BOLD}New compression ratio for file ${count}/${#@} ${UNDERLINE}"$(basename "${f%.*}_${suffix}.mp4")"${NC}${GREEN}${BOLD} is: ${recompression_ratio} ${NC}"
        fi
    ((count++))
done

# 11. Exporting [udta] atom to *.txt using bento4/mp4extract

count="1"
for f in "$@"; do
    echo -e "${GREEN}Exporting [udta] atom using Bento4 SDK from file ${count}/${#@} ${UNDERLINE}"${f##*/}"${NC}"
    echo -e "${BLUE}mp4extract moov/udta ${UNDERLINE}"$(basename "${f}")"${NC} ${BLUE}"$(basename "${f%.*}.txt")"${NC}"
    $mp4extract moov/udta "${f}" "${f%.*}.txt" || exit 1
    ((count++))
done

# 12. Importing [udta] atom to compressed video files using bento4/mp4edit

count="1"
for f in "$@"; do
    if [ -e "${f%.*}.txt" ]; then
    echo -e "${GREEN}Importing metadata using Bento4 SDK from file ${count}/${#@} ${UNDERLINE}"$(basename "${f%.*}.txt")"${NC} ${GREEN}to ${UNDERLINE}"$(basename "${f%.*}_${suffix}_${suffix2}.mp4")"${NC}"
    echo -e "${BLUE}mp4edit --insert moov: ${UNDERLINE}"$(basename "${f%.*}.txt")"${NC} ${BLUE}${UNDERLINE}"$(basename "${f%.*}_${suffix}.mp4")"${NC} ${BLUE}${UNDERLINE}"$(basename "${f%.*}_${suffix}_${suffix2}.mp4")"${NC}"
    $mp4edit --insert moov:"${f%.*}.txt" "${f%.*}_${suffix}.mp4" "${f%.*}_${suffix}_${suffix2}.mp4" || exit 1
    fi
    ((count++))
done

# 13. Verifying GPS metadata of the compressed files

count="1"
for f in "$@"; do
    if [ -e "${f%.*}_${suffix}_${suffix2}.mp4" ]; then
    echo -e "${GREEN}Reading GPS metadata using MediaInfo from file ${count}/${#@} ${UNDERLINE}"$(basename "${f%.*}_${suffix}_${suffix2}.mp4")"${NC}"
    echo -e "${BLUE}mediainfo ${UNDERLINE}"$(basename "${f%.*}_${suffix}_${suffix2}.mp4")"${NC} ${BLUE} | grep "©xyz" | head -n 1 ${NC}"
            if mediainfo "${f%.*}_${suffix}_${suffix2}.mp4" | grep -q "©xyz" | head - n 1 2> /dev/null; then
            echo -e "${RED}${BOLD}WARNING!!! No GPS information found! File ${count}/${#@} ${UNDERLINE}"$(basename "${f%.*}_${suffix}_${suffix2}.mp4")"${NC}"
#            read -p "Would you like to continue ? (y/n)  " answer_continue_1
#                if [[ $answer_continue_1 = "y" ]]; then
#                echo -e "${GREEN}Proceeding to the next step${NC}"
#                else
#                exit 1
#                fi
            else
            echo -e "${GREEN}File ${count}/${#@} ${UNDERLINE}"$(basename "${f%.*}_${suffix}_${suffix2}.mp4")"${NC} ${GREEN}contains GPS metadata${NC}"
            mediainfo "${f%.*}_${suffix}_${suffix2}.mp4" | grep "©xyz" | head -n 1
            fi
    else
    echo -e "${RED}${BOLD}File not found! ${count}/${#@} ${UNDERLINE}"$(basename "${f%.*}_${suffix}_${suffix2}.mp4")"${NC}"
#            read -p "Would you like to continue ? (y/n)  " answer_continue_2
#                if [[ $answer_continue_2 = "y" ]]; then
#                echo -e "${GREEN}Proceeding to the next step${NC}"
#                else
#                exit 1
#                fi
    fi
    ((count++))
done

# 14. Deleting temporary *.txt files

count="1"
for f in "$@"; do
    if [ -e "${f%.*}.txt" ]; then
    echo -e "${ORANGE}Deleting file ${count}/${#@} ${UNDERLINE}"$(basename "${f%.*}.txt")"${NC}"
    rm -f "${f%.*}.txt"
    fi
    ((count++))
done

# 15. Writing FileModifyDate from QuickTime:CreateDate using exiftool

count="1"
for f in "$@"; do
    if [ -e "${f%.*}_${suffix}_${suffix2}.mp4" ]; then
    echo -e "${GREEN}Copying QuickTime.CreateDate to FileModifyDate using ExifTool for file ${count}/${#@} ${UNDERLINE}"$(basename "${f%.*}_${suffix}_${suffix2}.mp4")"${NC}"
    echo -e "${BLUE}exiftool -api quicktimeutc=1 '-FileModifyDate<QuickTime:CreateDate' -overwrite_original ${UNDERLINE}"$(basename "${f%.*}_${suffix}_${suffix2}.mp4")"${NC}"
    exiftool -api quicktimeutc=1 "-FileModifyDate<QuickTime:CreateDate" -overwrite_original "${f%.*}_${suffix}_${suffix2}.mp4" || exit 1
    fi
    ((count++))
done


# 16. Deleting temporary "${f%.*}_${suffix}.mp4"

count="1"
for f in "$@"; do
#    read -p "Would you like to delete file ${count}/${#@} "$(basename "${f%.*}_${suffix}.mp4")" ? (y/n)  " answer_delete_1
#    if [[ $answer_delete_1 = "y" ]]; then
    echo -e "${ORANGE}Deleting file ${count}/${#@} ${UNDERLINE}"$(basename "${f%.*}_${suffix}.mp4")"${NC}"
    rm -f "${f%.*}_${suffix}.mp4"
#    else
#    exit 1
#    fi
    ((count++))
done

# 17. Removing ${suffix2} from filenames

count="1"
for f in "$@"; do
    if [ -e "${f%.*}_${suffix}_${suffix2}.mp4" ]; then
    echo -e "${ORANGE}Renaming file ${count}/${#@} ${UNDERLINE}"$(basename "${f%.*}_${suffix}_${suffix2}.mp4")"${NC}${ORANGE} to ${ORANGE}${UNDERLINE}"$(basename "${f%.*}_${suffix}.mp4")"${NC}"
    mv "${f%.*}_${suffix}_${suffix2}.mp4" "${f%.*}_${suffix}.mp4"
#    else
#    exit 1
    fi
    ((count++))
done

# 18. Moving original files to "${store_originals_folder}"

count="1"
for f in "$@"; do
    read -p "Would you like to move ORIGINAL file ${count}/${#@} "$(basename "${f}")" to "${store_originals_folder}" ? (y/n)  " answer_move_1
if [[ $answer_move_1 = "y" ]]; then
    echo -e "${ORANGE}Moving file ${count}/${#@} ${UNDERLINE}"$(basename "${f}")"${NC}${ORANGE} to ${BOLD}"${store_originals_folder}"${NC}"
    mv "${f}" "${store_originals_folder}"/"$(basename "${f}")"
#    else
#    exit 1
    fi
 ((count++))
done

# Done

popd
echo -e "${GREEN}${BOLD} Your files have been processed. Please review all the messages above. Warnings displayed in${RED}${BOLD} RED ${GREEN}${BOLD}color.${NC}"
echo -e "${GREEN}${BOLD} Press any key to close the window${NC}"
read -n1
