#!/bin/sh

cd ~/.config/hypr
find config/ -name autoconfigure.sh -exec sh {} \;
