#!/usr/bin/env bash

##### WARNING #####
## THIS NUKES ALL LOCAL DOCKER CONTAINERS & IMAGES
##

# Stop all containers
docker stop $(docker ps -a -q)
# Delete all containers
docker rm $(docker ps -a -q)
# Delete all images
docker rmi -f $(docker images -q)
