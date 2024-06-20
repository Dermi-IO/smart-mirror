#!/bin/bash

if xset q | grep -q 'Screen Saver:';
then
    DISPLAY=:0 xdotool mousemove 0 0
fi