#!/usr/bin/env bash
#
# create animated gif
#
mogrify -resize 800x800^ img/mixed/1*.png
convert -delay 100 -loop 0 img/mixed/1*.png img/rmny-animated-mixed.gif
