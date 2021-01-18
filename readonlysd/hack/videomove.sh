#!/bin/sh

###################################################################################################
## Moves ffmpeg's output the corresponding directory, and renames it to show the recording date. ##
## Deletes old videos when there is not enough free space on the SD card.                        ##
## Author: DBaluxa                                                                               ##
###################################################################################################

# include config
. /media/config.txt
files=$videoDir/*.mkv

while true
do
  sleep 2
  
  #Moving video files to directories if the time sync is OK
  year=`date +%Y`
  if [ $year != 1970 ]
  then
    day=`date +%Y-%m-%d`
    ts=`date +%Y%m%d_%H_%M_%S`
    if [ ! -d $videoDir/$day ] 
    then 
      mkdir $videoDir/$day
    fi
    for i in $files
    do
      if [ "$i" != "$files" ]  
      then
        mv $i $videoDir/$day/${ts}_`basename $i`
      fi
    done
  fi
  
  #Removing files when filesystem is full
  freeMb=`df -Phm $videoDir | tail -1 | awk '{print $4}' | sed 's/G/ 1000/g' | sed 's/M/ 1/g'  |awk '{printf "%.0f\n", $1 * $2}'`
  #echo Free space: $freeMb
  if [ $freeMb -le $MinFreeSpaceMb ] 
  then
    for dir in `ls $videoDir`
    do
      if [ -d $videoDir/$dir ] 
      then
        dirEmpty=true
        for file in `ls $videoDir/$dir`
        do
          freeMb=`df -Phm $videoDir | tail -1 | awk '{print $4}' | sed 's/G/ 1000/g' | sed 's/M/ 1/g'  |awk '{printf "%.0f\n", $1 * $2}'`
          echo Free space: $freeMb
          if [ $freeMb -le $MinFreeSpaceMb ]
          then  
            echo Removing $videoDir/$dir/$file
            rm $videoDir/$dir/$file
          else
            dirEmpty=false
            break;
          fi
        done
        if [ $dirEmpty = true ] 
        then
          echo Removing empty directory $dir
          rmdir $videoDir/$dir
        fi
      fi
    done 
    sync
  fi 
done
