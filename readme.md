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

This environment can be easily changed to build Linux image to other Raspbery Pi models. Please check the directory `${YOCTO_SRC_PATH}/meta-raspberrypi/conf/machine` for the supported RPi models.

## Package repositories

This docker image can also serve as a package repository for the embedded devices. The packages (ipk, rpm, or deb) generated by Yocto are located, for instance, in `/mnt/yocto/tmp/deploy/rpm`.  So, in the docker image, open a terminal in this directory and run `python -m SimpleHTTPServer` to create the webserver. Execute `ifconfig` to get the docker image IP address.

Now, in the host computer, you will be able to run `firefox http://localhost:8000/` having access to the packages generated by Yocto in the docker image. The next step is to setup the embedded computer...


### Set up target embedded computer 

Assuming the embedded computer is already deployed and it is in the same network as the docker image, it is possible to also have access to the package repository. 
Follow [these](https://github.com/VSChina/yocto-101/blob/master/configure_package_manager.md) steps to configure the embedded computer:

Create a directory for repos.
```
$ mkdir -p /etc/yum.repos.d 
```
Add repo with name end with `.repo`. For example, we add a `oe-packages.repo` under `/etc/yum.repo.d/` directory.
```
[oe-packages]
name=oe-packages
baseurl=http://<server-machine-ip>:8000
enabled=1
gpgcheck=0
```
Replace `<server-machine-ip>` with your server machine ip, like `baseurl=http://<docker image IP address>:8000` in my case.

Once you have informed DNF where to find the package databases, you need to fetch them:
```
$ dnf makecache
oe-packages                                    3.9 MB/s | 2.3 MB     00:00
```
After that you can install package you want.
```
$ dnf install <package-name>
```
DNF is now able to find, install, and upgrade packages from the specified repository or repositories.

## TODO

 - [x] Include [package repository webserver](https://community.nxp.com/t5/i-MX-Processors-Knowledge-Base/Setting-up-a-package-management-service-in-Yocto-for-your-image/ta-p/1108179) or like [this](https://github.com/VSChina/yocto-101/blob/master/configure_package_manager.md). Feature under test...

## Others

Similar initiatives:

 - https://github.com/kylefoxaustin/ubuntu_vnc_lxde_yocto

