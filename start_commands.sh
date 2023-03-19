#!/bin/bash

cp -r /cups-spool/. /var/spool/cups/.

/etc/init.d/dbus start
/etc/init.d/cups start

avahi-daemon &

cron -f | tee /root/cron.log
