#!/usr/bin/env bash
#
# create animated gif
#
mogrify -resize 800x800^ img/publications/1*.png
convert -delay 100 -loop 0 img/publications/1*.png img/rmny-animated.gif
