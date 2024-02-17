FROM ubuntu:20.04

ENV CUPSADMIN admin
ENV CUPSPASSWORD admin

ADD start_commands.sh /root/start_commands.sh

#Add cron script to docker image
ADD biweekly_colour_print.sh /root/biweekly_colour_print.sh

#Give execution rights to the cron script
RUN chmod 644 /root/biweekly_colour_print.sh

#Add Canon printer driver
ADD cnijfilter2-5.40-1-deb.tar /root/cnijfilter2-5.40-1-deb.tar

#Install sudo for script compatibility, set up timeinfo, and install cron
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qqy && apt-get -y install tzdata sudo cron rsync enscript qpdf && \
    ln -fs /usr/share/zoneinfo/America/Edmonton /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

#Install prerequisite packages
RUN cd /root/cnijfilter2-5.40-1-deb.tar/cnijfilter2-5.40-1-deb/packages && \
    apt-get update -qqy && apt-get install -y cups dialog apt-utils syslog-ng

#Install driver
RUN DEBIAN_FRONTEND=noninteractive TZ=America/Edmonton && cd /root/cnijfilter2-5.40-1-deb.tar/cnijfilter2-5.40-1-deb/packages && \
    apt-get install -y ./cnijfilter2_5.40-1_amd64.deb

#Add config to cupsd.conf enable webpage access and admin user rights
RUN sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
    sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
    sed -i 's/JobPrivateValues default/JobPrivateValues none/' /etc/cups/cupsd.conf && \
    sed -i 's/SubscriptionPrivateValues default/SubscriptionPrivateValues none/' /etc/cups/cupsd.conf && \
    echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
    echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf && \
    echo "PreserveJobFiles Yes" >> /etc/cups/cupsd.conf && \
    echo "PreserveJobHistory Yes" >> /etc/cups/cupsd.conf

#Add admin user for CUPS administration
RUN useradd ${CUPSADMIN}

#IMPORTANT: Critical command to get admin authentication via web page
#RUN echo "admin:admin" | chpasswd
RUN echo ${CUPSADMIN}:${CUPSPASSWORD} | chpasswd

#Add admin to lpadmin to use in webpage
RUN usermod -aG lpadmin ${CUPSADMIN}

#Install avahi-daemon to broadcast bonjour/airprint/zeroconf
#RUN apt install avahi-daemon

#Run printer find-and-install script (install first printer found)
RUN bash /root/cnijfilter2-5.40-1-deb.tar/cnijfilter2-5.40-1-deb/install.sh

#Add the biweekly color print cron job
RUN crontab -l | { cat; echo "0 0 * * 0,3 bash /root/biweekly_colour_print.sh >> /root/cron.log 2>&1"; } | crontab -

#Add rsync to save print job history outside docker container
RUN crontab -l | { cat; echo "* * * * * rsync -a --chown nobody:nogroup --chmod 777 /var/spool/cups/ /cups-spool/ >> /root/cron.log 2>&1"; } | crontab -

#RUN crontab -l | { cat; echo "*/1 * * * * /usr/sbin/service avahi-daemon restart >> /root/cron.log 2>&1"; } | crontab -

#Run the command on container startup
ENTRYPOINT /root/start_commands.sh
