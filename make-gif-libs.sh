#!/usr/bin/env bash
#
# create animated gif
#
mogrify -resize 1200x1200^ img/libraries/1*.png
convert -delay 100 -loop 0 img/libraries/1*.png img/rmny-libs-animated.gif
