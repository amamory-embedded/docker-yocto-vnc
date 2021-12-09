#!/bin/bash

# Host must have a directory called '$HOME/docker_share' to be able to take the generated image
# run:  
#  $ firefox 6080:80

docker run -p 6080:80 -v $HOME/docker_share:/home/build yocto_vnc