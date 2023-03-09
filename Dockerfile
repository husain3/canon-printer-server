#Dockerfile to create image for printer maintenance
FROM ubuntu:20.04

#Add cron script to docker image
ADD biweekly_colour_print.sh /root/biweekly_colour_print.sh

#Give execution rights to the cron script
RUN chmod 644 /root/biweekly_colour_print.sh

#Add Canon printer driver
ADD cnijfilter2-5.40-1-deb.tar /root/cnijfilter2-5.40-1-deb.tar

#Install sudo for script compatibility, set up timeinfo, and install cron
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qqy && apt-get -y install tzdata sudo cron enscript qpdf && \
    ln -fs /usr/share/zoneinfo/America/Edmonton /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

#Install prerequisite packages
RUN cd /root/cnijfilter2-5.40-1-deb.tar/cnijfilter2-5.40-1-deb/packages && \
    apt-get update -qqy && apt-get install -y cups dialog apt-utils syslog-ng

#Install driver
RUN DEBIAN_FRONTEND=noninteractive TZ=America/Edmonton && cd /root/cnijfilter2-5.40-1-deb.tar/cnijfilter2-5.40-1-deb/packages && \
    apt-get install -y ./cnijfilter2_5.40-1_amd64.deb

#Run printer find-and-install script (install first printer found)
RUN bash /root/cnijfilter2-5.40-1-deb.tar/cnijfilter2-5.40-1-deb/install.sh

#Add the cron job
RUN crontab -l | { cat; echo "0 0 * * 0,3 bash /root/biweekly_colour_print.sh >> /root/cron.log 2>&1"; } | crontab -

#Run the command on container startup
ENTRYPOINT cron -f | tee /root/cron.log
