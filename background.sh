#!/bin/bash
# create background cpu occupy rate between 11% and 20%. Avoid statistic idle

stress --cpu 1 --timeout 60 && cpulimit -l $((11 + $(od -An -N1 -i /dev/urandom) % 10)) -p $(pidof stress)
