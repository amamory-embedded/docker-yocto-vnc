#!/bin/bash

# Host must have a directory called '$HOME/docker_share' to be able to take the generated image

echo "run on another terminal : $ firefox http://localhost:6080/"
sleep 3

docker run -p 6080:80 -v $HOME/docker_share:/home/build yocto_vnc