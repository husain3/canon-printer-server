#Dockerfile to create image for printer maintenance
FROM ubuntu:20.04 AS build

#Add Canon printer driver
ADD cnijfilter2-5.40-1-deb.tar /root/cnijfilter2-5.40-1-deb.tar

#Install sudo for script compatibility  and set up timeinfo
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Edmonton
RUN apt-get update -qqy && apt-get -y install tzdata sudo

#Install prerequisite packages
RUN cd /root/cnijfilter2-5.40-1-deb.tar/cnijfilter2-5.40-1-deb/packages && \
    apt-get update -qqy && apt-get install -y cups dialog apt-utils

#Install driver
RUN DEBIAN_FRONTEND=noninteractive TZ=America/Edmonton && cd /root/cnijfilter2-5.40-1-deb.tar/cnijfilter2-5.40-1-deb/packages && \
    apt-get install -y ./cnijfilter2_5.40-1_amd64.deb

#Run printer find-and-install script (install first printer found)
RUN bash /root/cnijfilter2-5.40-1-deb.tar/cnijfilter2-5.40-1-deb/install.sh
