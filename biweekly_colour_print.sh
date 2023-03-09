#!/bin/bash

#This script overlays the date and time onto the default ubuntu testpage.
#Helps with making sure cron job is working

tmpfile=$(mktemp) && echo $(date) | \
    enscript -B -f Courier-Bold16 -o- | \
    ps2pdf - "$tmpfile" && qpdf /usr/share/cups/data/default-testpage.pdf --overlay "$tmpfile" -- datetime_testpage.pdf && \
    lp datetime_testpage.pdf
