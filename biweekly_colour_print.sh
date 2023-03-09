#!/bin/bash

#IMPORTANT
#media is 'Letter' because it is using the normal paper in the upper tray
#(media=Letter)

#The lower tray is Legal sized and reserved for the printer cleaning sheets
#(media=Legal)

tmpfile=$(mktemp) && echo $(date) | \
    enscript -B -f Courier-Bold16 -o- | \
    ps2pdf - "$tmpfile" && qpdf /usr/share/cups/data/default-testpage.pdf --overlay "$tmpfile" -- datetime_testpage.pdf && \
    lp -o media=Letter datetime_testpage.pdf
