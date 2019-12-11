FROM fedora:29

ENV DEBIAN_FRONTEND noninteractive
ENV TERM=linux

#FIX
RUN sed -i 's/metalink=https/#metalink=https/g' /etc/yum.repos.d/*.repo
RUN sed -i 's/#baseurl/baseurl/g' /etc/yum.repos.d/*.repo
RUN sed -i 's/download.fedoraproject.org\/pub/fedora.mirror.garr.it/g' /etc/yum.repos.d/*.repo

RUN yum install -y git python2 #file which

#requirements for httpserver-html5-cli (nodejs,npm), cloud-init (cargo), ffmpeg (yasm), additional utility libraries
RUN yum install -y nodejs npm cargo yasm vim telnet net-tools

#
# PREPARE ENVIRONMENT
#

# - prepare directories
RUN mkdir /git-repos /result
# - clone OSv
WORKDIR /git-repos
#RUN git clone https://github.com/cloudius-systems/osv.git
RUN git clone git://github.com/cloudius-systems/osv.git
WORKDIR /git-repos/osv
RUN git submodule update --init --recursive
RUN scripts/setup.py

#FIX
RUN update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-1.8.0-openjdk/bin/javac 1
RUN update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-1.8.0-openjdk/bin/java 1
RUN yum install -y make


#install capstan and update PATH
RUN wget -O - https://raw.githubusercontent.com/mikelangelo-project/capstan/master/scripts/download | bash
ENV PATH="/root/bin:${PATH}"

#copy script files
RUN mkdir /scripts
COPY ./scripts /scripts/
RUN chmod +x /scripts/*.sh

#RUN /scripts/build_packages.sh osv_loader_and_bootstrap
#RUN /scripts/build_packages.sh openjdk8-full
#RUN /scripts/build_packages.sh python
#RUN /scripts/build_packages.sh node
#RUN /scripts/build_packages.sh generic_app "nginx" "1.14.2" "" 
#RUN /scripts/build_packages.sh generic_app "haproxy" "1.5.8" "" 
#RUN /scripts/build_packages.sh generic_app "ffmpeg" "4.0.2" "/ffmpeg.so -formats" 


#cmd
CMD /bin/bash

#
# NOTES
#
# Build this container with:
# docker build -t osv/composer .
#
# Run this container with:
# docker run -it --privileged --volume="/repo:/root/.capstan" osv/composer
# 

