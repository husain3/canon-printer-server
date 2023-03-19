#!/bin/bash

/etc/init.d/dbus start
/etc/init.d/cups start

avahi-daemon &

cron -f | tee /root/cron.log
