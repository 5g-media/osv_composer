FROM fedora:29

ENV DEBIAN_FRONTEND noninteractive
ENV TERM=linux

#FIX
RUN sed -i 's/metalink=https/#metalink=https/g' /etc/yum.repos.d/*.repo
RUN sed -i 's/#baseurl/baseurl/g' /etc/yum.repos.d/*.repo
RUN sed -i 's/download.fedoraproject.org\/pub/fedora.mirror.garr.it/g' /etc/yum.repos.d/*.repo


RUN yum install -y git python2 file which wget npm

#requirements
COPY setup.py setup.py
RUN python setup.py

#openstack client
RUN yum install -y python-devel python-pip
RUN pip install python-openstackclient

#OSM client
#RUN yum install -y python-pip libcurl-devel gnutls-devel
#RUN pip install git+https://osm.etsi.org/gerrit/osm/osmclient@v5.0.5
#RUN pip uninstall -y pycurl
#ENV PYCURL_SSL_LIBRARY=openssl
#RUN pip install pycurl

#install capstan and update PATH
RUN wget -O - https://raw.githubusercontent.com/mikelangelo-project/capstan/master/scripts/download | bash
ENV PATH="/root/bin:${PATH}"

#copy script files and examples
RUN mkdir /scripts
COPY *.sh /scripts/
COPY examples/* /scripts/
RUN chmod +x /scripts/*.sh

#cmd
CMD /bin/bash

#
# NOTES
#
# Build this container with:
# docker build -t osv/runner .
#
# Run this container with:
# docker run -it --privileged --volume="/repo:/root/.capstan" osv/runner
# 

