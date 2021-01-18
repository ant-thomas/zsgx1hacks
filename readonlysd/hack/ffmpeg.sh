#!/bin/sh

############################################################
## Starts ffmpeg process to save the video stream locally ##
## Author: DBaluxa                                        ##
############################################################

# include config
. /media/config.txt

while true
do
  sleep 30
  /media/hack/ffmpeg -i rtsp://admin:$rtspPasswd@127.0.0.1:8001/0/av0 -vcodec copy -acodec copy -map 0 -f segment -segment_time 1200 -v error $videoDir/%04d.mkv </dev/null
done

