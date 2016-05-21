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

function checkImage() {
	if [[ "$(docker images -q "$1")" = "" ]]; then
		return 0
	else
		return 1
	fi
}

function runInteractive() {
	omniIpToUse=$1
	usrpIpToUse=$2
	domainName=$3
	shift 3
	docker run --net=host --rm -e OMNISERVICEIP=$omniIpToUse -e RHUSRPARGS="--usrpip=$usrpIpToUse" -e RHUSRPNAME="N210_" -e RHDOMAINNAME=$domainName -i -t "$@" redhawk-usrp-uhd bash -l -c "uhd_find_devices && nodeBooter -d \$SDRROOT/dev/nodes/usrpNode_\$RHUSRPNAME\$USRP_ID/DeviceManager.dcd.xml" 
}

function runNonInteractive() {
	omniIpToUse=$1
	usrpIpToUse=$2
	domainName=$3
	shift 3
	docker run --net=host --rm -e OMNISERVICEIP=$omniIpToUse -e RHUSRPARGS="--usrpip=$usrpIpToUse" -e RHUSRPNAME="N210_" -e RHDOMAINNAME=$domainName "$@" redhawk-usrp-uhd
}

# Make sure the correct images are built already
checkImage "redhawk-deps"

if [ $? == 0 ]; then
	echo "Image 'redhawk-deps' is not available. Run build.sh"
	exit 1
fi

checkImage "redhawk-base"

if [ $? == 0 ]; then
	echo "Image 'redhawk-base' is not available. Run build.sh"
	exit 1
fi

checkImage "redhawk-usrp-uhd"

if [ $? == 0 ]; then
	echo "Image 'redhawk-usrp-uhd' is not available. Run build.sh"
	exit 1
fi

# Check provided options
domainName="REDHAWK_DEV"
omniIpToUse=""
teletypeEnabled=true
usrpIpToUse=""

while getopts "i:u:d?n" opt; do
	case $opt in
		i)
			omniIpToUse=$OPTARG
			;;
		d)
			domainName=$OPTARG
			;;
		n)
			teletypeEnabled=false
			;;
		u)
			usrpIpToUse=$OPTARG
			;;
		*)
			if [ "$opt" == "--" ]; then
				shift
				break
			fi
	esac
done

# Grab the rest of the arguments and pass them to docker run
shift $((OPTIND-1))

# Check if the Domain Manager IP address was provided
if [ "$omniIpToUse" == "" ]; then
	echo "The IP address of the Domain Manager must be provided"
	exit 1
fi

# Check if the N210 IP address was provided
if [ "$usrpIpToUse" == "" ]; then
	echo "The IP address of the N210 must be provided"
	exit 1
fi

# Run the docker container as a device manager
if [ "$teletypeEnabled" = true ]; then
	runInteractive $omniIpToUse $usrpIpToUse $domainName "$@"
else
	runNonInteractive $omniIpToUse $usrpIpToUse $domainName "$@"
fi

