#!/usr/bin/env bash
#
# create animated gif
#
mogrify -resize 800x800^ img/1*.png
convert -delay 100 -loop 0 img/*.png img/rmny-animated.gif
