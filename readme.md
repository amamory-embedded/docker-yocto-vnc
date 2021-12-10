# Docker-Yocto-VNC

[![Docker Hub](https://img.shields.io/docker/pulls/amamory/docker-yocto-vnc.svg?style=flat-square)](https://hub.docker.com/r/amamory/docker-yocto-vnc/)

Docker image for Yocto 3.1 (Dunfell) based on Ubuntu 18.04 (bionic) with support to VNC. It also includes the layers to build Linux for Raspberry Pi 3.

This docker file is build on top of [docker-ubuntu-vnc-desktop](https://github.com/fcwu/docker-ubuntu-vnc-desktop) which provides pre-built docker with VNC support. This Dockerfile uses `dorowu/ubuntu-desktop-lxde-vnc:bionic-lxqt`.

## Downloading a pre-built Docker image

```
$ docker pull amamory/docker-yocto-vnc
```

Then you can skip the next section.

## Building the image

```
$ git clone https://github.com/amamory/yocto_docker_vnc
$ cd yocto_docker
$ ./build-image.sh
```

## Starting the container

When running the image, the user has to pass a directory where the yocto cache and the resulting image will be saved in the host computer. This way, it is possible to do an incremental design, running the image multiple time without starting over again.

```
$ ./start_container.sh <cache-directory> <image-directory>
$ firefox http://localhost:6080/
```

## In the docker container

The directory `/opt/mnt` in the container has the Yocto cache. This directory is shared with the host. The directory `/home/build/rpi` in the container is also shared with the host so that the user can easily copy the resulting Linux image.

```
$ cd rpi
$ source ${YOCTO_SRC_PATH}/poky/oe-init-build-env
$ pwd 
rpi/build
```

Tweak the files `conf/bblayers.conf` and `conf/local.conf` to configure your RPi Linux Image. You might want to reuse the configuration files left in the `/home/build/template` directory. These files are already configured with a minimal system and pointing to the correct mounting places.

Execute the following command to see the installed Yocto images.

```
$ find ${YOCTO_SRC_PATH} -type f -path '*images/*' -name '*.bb'
```

One usual Yocto images is `core-image-base`.

```
$ bitbake core-image-base

```
