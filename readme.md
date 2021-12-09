# Docker-Yocto-VNC

Docker image for Yocto 3.1 (Dunfell) based on Ubuntu 18.04 (bionic) with support to VNC.
It also include the layers to build for Raspberry Pi 3.

This docker file is build on top of [docker-ubuntu-vnc-desktop](https://github.com/fcwu/docker-ubuntu-vnc-desktop) which provides pre-built docker. 
This Dockerfile uses `dorowu/ubuntu-desktop-lxde-vnc:bionic-lxqt`.

Building the image:

```
git clone https://github.com/amamory/yocto_docker_vnc
cd yocto_docker
./build-image.sh
```

Start container:
```
./start_container.sh
firefox 6080:80
```

Suggestion for adding a shortcut to starting the container:
```
sudo mkdir /opt/docker_aliases/ubuntu-bionic
cp start-container.sh /opt/docker_aliases/ubuntu-bionic
cd /opt/docker_aliases/ubuntu-bionic
sudo ln -s start_container.sh start-yocto
```

In the docker image, execute:

```
source ${YOCTO_PATH}/poky/oe-init-build-env
cd rpi/build
tweak the files `conf/bblayers.conf` and conf/local.conf
bitbake core-image-base
```

