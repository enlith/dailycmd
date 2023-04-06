#!/bin/bash
#
# use on 4 cpus machine to make backgroud cpu rate up > 10%
#
stress --cpu 1 --timeout 60 &
# Get the pid list from pgrep stress
pids=$(pgrep stress)

limit=$((36 + $(od -An -N1 -i /dev/urandom) % 10))

# Loop through each pid and echo it
for pid in $pids; do
  cpulimit -l $limit -p $pid &
done
