#!/bin/bash

GID=$(id -g)
SERVER="90.226.151.71"

# umount disks
echo "umount homeDisk1 and homeDisk2"
sudo umount  /home/ubuntu/homeDisk1
sudo umount  /home/ubuntu/homeDisk2
# read password
read -sp "enter password:" password
# mount folders
echo $password | sshfs -o uid=$UID -o gid=$GID \
    -o ServerAliveInterval=60 -o ServerAliveCountMax=2 \
    root@$SERVER:/storage/external_storage/sda2 /home/ubuntu/homeDisk1 -o password_stdin
echo $password | sshfs -o uid=$UID -o gid=$GID \
    -o ServerAliveInterval=60 -o ServerAliveCountMax=2 \
    root@$SERVER:/storage/external_storage/sda3 /home/ubuntu/homeDisk2 -o password_stdin
