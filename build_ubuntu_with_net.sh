#!/bin/bash
mkdir /tmp/ubuntu_with_nettool
cat >/tmp/ubuntu_with_nettool/Dockerfile <<'EOF'
FROM ubuntu
RUN apt-get update && apt-get install -y iputils-ping  net-tools wget
CMD bash
EOF
docker build -t ubuntu_with_nettool /tmp/ubuntu_with_nettool
rm -rf  /tmp/ubuntu_with_nettool
