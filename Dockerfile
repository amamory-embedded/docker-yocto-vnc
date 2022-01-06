# Dockerfile with Ubuntu 18.04, VNC, and Yocto Dunfell (3.1)
# this docker files combines two Dockerfiles:
#   https://raw.githubusercontent.com/yoctocookbook2ndedition/docker-yocto-builder/master/Dockerfile
#   https://hub.docker.com/r/dorowu/ubuntu-desktop-lxde-vnc/tags  

# Start Yocto install on top of another docker with pre-built VNC and Ubuntu 18.04
# Source: 
# https://github.com/fcwu/docker-ubuntu-vnc-desktop
# https://hub.docker.com/r/dorowu/ubuntu-desktop-lxde-vnc/tags
FROM dorowu/ubuntu-desktop-lxde-vnc:bionic-lxqt

LABEL maintainer="alexandre.amory@santannapisa.it, amamory@gmail.com"

# Yocto install based on 
# https://raw.githubusercontent.com/yoctocookbook2ndedition/docker-yocto-builder/master/Dockerfile
# but upgrated to Ubuntu 18.04
RUN apt-get update && apt-get -y upgrade && apt-get -y install gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat cpio python python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping libsdl1.2-dev xterm curl file bmaptool

# Set up locales
RUN apt-get -y install locales apt-utils sudo && dpkg-reconfigure locales && locale-gen en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG en_US.utf8

# install any other package you want in the docker image
RUN apt-get update && apt-get -y install tree nano htop figlet geany autoconf cmake cmake-curses-gui libncurses-dev screen

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Replace dash with bash
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Set the username
ENV USER build

# User management
RUN groupadd -g 1000 ${USER} && useradd -u 1000 -g 1000 -ms /bin/bash ${USER} && usermod -a -G sudo ${USER} && usermod -a -G users ${USER}
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Install repo
RUN curl -o /usr/local/bin/repo https://storage.googleapis.com/git-repo-downloads/repo && chmod a+x /usr/local/bin/repo

# Set the Yocto release
ENV YOCTO_RELEASE "dunfell"
# Run as build user from the installation path
ENV YOCTO_PATH "/opt/yocto/${YOCTO_RELEASE}"
ENV YOCTO_SRC_PATH "${YOCTO_PATH}/src"
RUN mkdir -p ${YOCTO_SRC_PATH}
RUN chown -R build /opt/yocto
#RUN install -o 1000 -g 1000 -d $YOCTO_BASE_PATH
RUN cp /etc/skel/.bashrc /home/${USER}
# mounting place for sstate, cache and downloads. Usefull for incremental Linux design
RUN mkdir -p /mnt/yocto && chmod 777 /mnt/yocto

USER ${USER}

# Install Poky 
RUN cd ${YOCTO_SRC_PATH} && git clone --branch ${YOCTO_RELEASE} https://git.yoctoproject.org/poky

# Install raspberry support and required layers
RUN cd ${YOCTO_SRC_PATH} && git clone --branch ${YOCTO_RELEASE} https://git.yoctoproject.org/meta-raspberrypi 
RUN cd ${YOCTO_SRC_PATH} && git clone --branch ${YOCTO_RELEASE} https://git.openembedded.org/meta-openembedded
# add here any other layer to be used

# mounting place with the host, where the image is created
RUN mkdir -p /home/${USER}/rpi/

# building the template project
RUN mkdir -p /home/${USER}/template/build
RUN source ${YOCTO_SRC_PATH}/poky/oe-init-build-env /home/${USER}/template/build
RUN tree /home/${USER}/template/build

# set the target machine, cache dir, and desired tools in conf/local.conf
# How to add apt-get https://imxdev.gitlab.io/tutorial/How_to_apt-get_to_the_Yocto_Project_image/
RUN cd /home/${USER}/template/build && echo -e "\
MACHINE = \"raspberrypi3\" \n\
IMAGE_INSTALL_append += \" nano\" \n\ 
IMAGE_INSTALL_append += \" htop\" \n\ 
PACKAGE_FEED_URIS = \"http://localhost:5678\" \n\ 
SSTATE_DIR = \"/mnt/yocto/shared-sstate-cache\" \n\
DL_DIR = \"/mnt/yocto/downloads\" \n\
TMPDIR = \"/mnt/yocto/tmp\" \n\
  " >> conf/local.conf
RUN figlet "conf/local.conf"
RUN cd /home/${USER}/template/build && cat conf/local.conf

# Some extra parameters that might interest
# EXTRA_IMAGE_FEATURES ?= "debug-tweaks"
# #  "tools-sdk"      - add development tools (gcc, make, pkgconfig etc.)
# #  "tools-debug"    - add debugging tools (gdb, strace)
# #  "tools-profile"  - add profiling tools (oprofile, lttng, valgrind)

# add the new layers to conf/bblayers.conf
RUN cd /home/${USER}/template/build && echo -e "\
BBLAYERS += \" \\ \n\
  ${YOCTO_SRC_PATH}/meta-raspberrypi \\ \n\
  ${YOCTO_SRC_PATH}/meta-openembedded/meta-oe  \\ \n\
  ${YOCTO_SRC_PATH}/meta-openembedded/meta-networking  \\ \n\
  ${YOCTO_SRC_PATH}/meta-openembedded/meta-python  \\ \n\
  \"" >> conf/bblayers.conf
RUN figlet "conf/bblayers.conf"
RUN cd /home/${USER}/template/build && cat conf/bblayers.conf

# add usefull commands for the docker user 
RUN echo -e "\
alias find_images=\"find /opt/yocto/dunfell/src/ -type f -path '*images/*' -name '*.bb'\" \n\
echo -e \"Run: source ${YOCTO_SRC_PATH}/poky/oe-init-build-env\" \n\
  " >> /home/${USER}/.bashrc

# Make /home/build the working directory
WORKDIR /home/${USER}
CMD /bin/bash
