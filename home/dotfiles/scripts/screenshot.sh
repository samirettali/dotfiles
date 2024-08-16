#!/usr/bin/env bash

mode=$(echo -e "output\nactive\nscreen\narea" | bemenu -l 4)
grimblast --notify --freeze copysave ${mode}
