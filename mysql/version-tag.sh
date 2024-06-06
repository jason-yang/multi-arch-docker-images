#!/usr/bin/env bash

curl -H "Cache-Control: no-cache" -sL "https://raw.githubusercontent.com/alpine-docker/multi-arch-docker-images/stable/functions.sh" -o functions.sh
source functions.sh

image="alpine/mysql"

# 15.1
version=$(docker run -ti --rm ${image} --version |awk '$1=$1' |awk '/mysql/{print $3}')

install_crane
./crane copy ${image} ${image}:${version}
