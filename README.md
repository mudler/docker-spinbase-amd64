# Sabayon Spinbase Docker image 

[![Circle CI](https://circleci.com/gh/Sabayon/docker-spinbase-amd64.svg?style=svg)](https://circleci.com/gh/Sabayon/docker-spinbase-amd64)

The purpose of this project is to provide an image of Sabayon spinbase.
It is just a [Sabayon base](https://github.com/mudler/docker-sabayon-base) with upgrades and tools, ready to be shipped on VM(s)/LiveCDs

Images are also on Docker Hub [sabayon/spinbase-amd64](https://registry.hub.docker.com/u/sabayon/spinbase-amd64/) and the already squashed image, 
[sabayon/spinbase-amd64-squashed](https://registry.hub.docker.com/u/sabayon/spinbase-amd64-squashed/)

## First steps on docker

Ensure to have the daemon started and running:

    sudo systemctl start docker

## Building sabayon-spinbase locally

    git clone https://github.com/mudler/docker-sabayon-spinbase-amd64.git docker-sabayon-spinbase
    cd docker-sabayon-spinbase
    sudo docker build -t sabayon/spinbase-amd64 .

## Pulling sabayon-spinbase from Docker Hub

    sudo docker pull sabayon/spinbase-amd64

## Converting the image from Docker to use it with [Molecules](https://github.com/Sabayon/molecules) as base chroot

Install [docker-companion](https://github.com/mudler/docker-companion) or download the pre-compiled version:

    curl -s https://api.github.com/repos/mudler/docker-companion/releases/latest \
    | grep "browser_download_url.*amd64" \
    | cut -d : -f 2,3 \
    | tr -d \" \
    | wget -i - -O docker-companion
    
and then as root:

    ./docker-companion unpack sabayon/spinbase-amd64 /my/path



