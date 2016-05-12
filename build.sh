#!/bin/bash
#
# This file is protected by Copyright. Please refer to the COPYRIGHT file
# distributed with this source distribution.
#
# This file is part of Docker REDHAWK USRP.
#
# Docker REDHAWK USRP is free software: you can redistribute it and/or modify it under
# the terms of the GNU Lesser General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# Docker REDHAWK USRP is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
# details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see http://www.gnu.org/licenses/.
#

# Build an image
# Args:
#  $1: image name
#  $2: directory containing Dockerfile
function buildImage() {
	docker build --rm -t "$1" "$2"
}

# Check if an image exists
# Args:
#  $1: image name
function checkImage() {
	if [[ "$(docker images -q "$1")" = "" ]]; then
		return 0
	else
		return 1
	fi
}

# Check for an image and build it if it doesn't exist
# Args:
#  $1: image name
#  $2: optional, directory containing Dockerfile, otherwise docker-$1 is assumed
function checkAndBuildImage() {
	dockerfileLocation="$2"

	if [ "$2" == "" ]; then
		dockerfileLocation="docker-$1"
	fi

	checkImage "$1"

	if [ $? == 0 ]; then
		buildImage $1 $dockerfileLocation
	fi

	checkImage "$1"

	if [ $? == 0 ]; then
		echo "Failed to build image $1"
		return 0
	fi

	return 1
}

# The images that this build script recognizes
SUPPORTED_IMAGES="redhawk-usrp-uhd"

# Check if an argument was provided to determine which images to build
if [ "$1" == "" ] || [ "$1" == "all" ]; then
	TO_BUILD='ALL'
else
	TO_BUILD=$1
fi

# If the user specified 'clean', remove the images and exit
if [ $TO_BUILD == "clean" ]; then
	docker rmi -f $SUPPORTED_IMAGES
	exit
fi

# Build the specified images
if [ $TO_BUILD == "ALL" ] || [ $TO_BUILD == "redhawk-usrp-uhd" ]; then
	checkAndBuildImage "redhawk-usrp-uhd" "docker-redhawk-usrp-uhd"

	if [ $? == 0 ]; then
		exit 1
	fi
fi
