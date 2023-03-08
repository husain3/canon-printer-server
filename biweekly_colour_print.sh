#!/bin/bash

#IMPORTANT
#media is 'Letter' because it is using the normal paper in the upper tray
#(media=Letter)

#The lower tray is Legal sized and reserved for the printer cleaning sheets
#(media=Legal)

lp -o media=Letter /usr/share/cups/data/default-testpage.pdf
