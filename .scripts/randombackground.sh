#!/bin/bash

find /home/amytcheng/Images/Wallpapers/ -type f \( -name '*.jpg' -o -name '*.png' \) -print0 | shuf -n1 -z | xargs -0 hsetroot -center
