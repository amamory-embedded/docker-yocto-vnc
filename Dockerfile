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
RUN apt-get update && apt-get -y upgrade && apt-get -y install gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat cpio python python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping libsdl1.2-dev xterm curl

# Set up locales
RUN apt-get -y install locales apt-utils sudo && dpkg-reconfigure locales && locale-gen en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG en_US.utf8

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Replace dash with bash
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# User management
RUN groupadd -g 1000 build && useradd -u 1000 -g 1000 -ms /bin/bash build && usermod -a -G sudo build && usermod -a -G users build

# Install repo
RUN curl -o /usr/local/bin/repo https://storage.googleapis.com/git-repo-downloads/repo && chmod a+x /usr/local/bin/repo

# Run as build user from the installation path
ENV YOCTO_INSTALL_PATH "/opt/yocto"
RUN install -o 1000 -g 1000 -d $YOCTO_INSTALL_PATH
RUN export USER=build
USER ${USER}
WORKDIR ${YOCTO_INSTALL_PATH}

# Set the Yocto release
ENV YOCTO_RELEASE "dunfell"

# Install Poky 
RUN cd ${YOCTO_INSTALL_PATH} && git clone --branch ${YOCTO_RELEASE} https://git.yoctoproject.org/poky

# Install FSL community BSP
# RUN mkdir -p ${YOCTO_INSTALL_PATH}/fsl-community-bsp && cd ${YOCTO_INSTALL_PATH}/fsl-community-bsp
# RUN repo init /usr/bin/yes
# RUN repo sync
# RUN repo init -u https://github.com/Freescale/fsl-community-bsp-platform -b ${YOCTO_RELEASE}
# RUN repo sync

# Install raspberry support and required layers
RUN cd ${YOCTO_INSTALL_PATH}/poky && git clone --branch ${YOCTO_RELEASE} https://git.yoctoproject.org/meta-raspberrypi 
RUN cd ${YOCTO_INSTALL_PATH}/poky && git clone --branch ${YOCTO_RELEASE} https://git.openembedded.org/meta-openembedded
RUN ls -lah /home
ENV USER build
RUN ls -lah /home/${USER} 
RUN cd /home/${USER} && pwd
RUN mkdir -p /home/${USER}/rpi/build
RUN source ${YOCTO_INSTALL_PATH}/poky/oe-init-build-env /home/${USER}/rpi/build
RUN apt-get update && apt-get -y install tree nano htop figlet geany file
RUN tree /home/${USER}/rpi/build
RUN cp /etc/skel/.bashrc /home/${USER}
ENV YOCTO_PATH ${YOCTO_INSTALL_PATH}

RUN figlet "LOCAL START"
RUN cd /home/${USER}/rpi/build && cat conf/local.conf
# set the target machine in conf/local.conf
RUN cd /home/${USER}/rpi/build && echo -e 'MACHINE = "raspberrypi3"' >> conf/local.conf
RUN cd /home/${USER}/rpi/build && echo -e 'CORE_IMAGE_EXTRA_INSTALL += "openssh"' >> conf/local.conf
RUN figlet "LOCAL MODIF"
RUN cd /home/${USER}/rpi/build && cat conf/local.conf

# add the new layers to conf/bblayers.conf
RUN figlet "BBLAYER START"
RUN cd /home/${USER}/rpi/build && cat conf/bblayers.conf
RUN cd /home/${USER}/rpi/build && echo -e "\
BBLAYERS += \" \\ \n\
  ${YOCTO_PATH}/poky/meta-raspberrypi \\ \n\
  ${YOCTO_PATH}/poky/meta-raspberrypi \\ \n\
  ${YOCTO_PATH}/poky/meta-openembedded/meta-oe  \\ \n\
  ${YOCTO_PATH}/poky/meta-openembedded/meta-networking  \\ \n\
  ${YOCTO_PATH}/poky/meta-openembedded/meta-python  \\ \n\
  \"" >> conf/bblayers.conf
RUN figlet "BBLAYER MODIF"
RUN cd /home/${USER}/rpi/build && cat conf/bblayers.conf
RUN figlet "BBLAYER END"
RUN echo -e "Run: source ${YOCTO_PATH}/poky/oe-init-build-env" 

#ENV MACHINE raspberrypi3

# Create a build directory for the FSL community BSP
# RUN mkdir -p ${YOCTO_INSTALL_PATH}/fsl-community-bsp/build

#RUN chmod -R ${YOCTO_INSTALL_PATH} build

# Improve rebuild performance by enabling compiler cache
# ENV USE_CCACHE 1
# ENV CCACHE_DIR /home/user/.ccache

# some QT-Apps/Gazebo do not show controls without this
# ENV QT_X11_NO_MITSHM 1

# Make /home/build the working directory
WORKDIR /home/${USER}
CMD /bin/bash
