#!/bin/bash

# Usage: ./start_container.sh <cache-directory> <image-directory>

[ "$1" == "" ] && { echo "Usage: $0 cache-directory image-directory"; exit 1; }
[ "$2" == "" ] && { echo "Usage: $0 cache-directory image-directory"; exit 1; }

# Host must have a directory where yocto will save sstate and downloads
YOCTO_CACHE=$1
if [ ! -d "${YOCTO_CACHE}" ]; then
  echo "Directory ${YOCTO_CACHE} DOES NOT exists."
  exit 1
fi
# check if the mounting places have at least 50G of space
FREE=`df -k --output=avail "${YOCTO_CACHE}" | tail -n1`   # df -k not df -h
if [[ $FREE -lt 52428800 ]]; then               # 50G = 50*1024*1024k
     # less than 50GBs free!
     echo "Directory ${YOCTO_CACHE} DOES NOT have 50GB free space." 
     exit 1
fi;

# Host must have a directory where yocto will write the generated image
YOCTO_IMAGE=$2
if [ ! -d "${YOCTO_IMAGE}" ]; then
  echo "Directory ${YOCTO_IMAGE} DOES NOT exists."
  exit 1
fi
# check if the mounting places have at least 50G of space
FREE=`df -k --output=avail "${YOCTO_IMAGE}" | tail -n1`   # df -k not df -h
if [[ $FREE -lt 52428800 ]]; then               # 50G = 50*1024*1024k
     # less than 50GBs free!
     echo "Directory ${YOCTO_IMAGE} DOES NOT have 50GB free space." 
     exit 1
fi;

echo "##########################################################"
echo "run on another terminal : $ firefox http://localhost:6080/"
echo "##########################################################"
sleep 3

# add `-u 0 ` to run as root
docker run -u 0 -p 6080:80 --mount src="$YOCTO_CACHE",target=/mnt/yocto,type=bind --mount src="$YOCTO_IMAGE",target=/home/build/rpi,type=bind amamory/docker-yocto-vnc