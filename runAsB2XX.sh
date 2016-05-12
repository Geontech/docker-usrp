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

# Check if the Domain Manager IP address is provided
if [ "$1" == "" ]; then
	echo "The IP address of the Domain Manager must be provided"
	exit 1
fi

# Check if a Domain Manager is provided
domainName="$2"

if [ "$2" == "" ]; then
	domainName="REDHAWK_DEV"
fi

# Run the docker container as a domain
docker run --net=host -e OMNISERVICEIP=$1 -e RHUSRPARGS="--usrptype=b200" -e RHUSRPNAME="B205_" -e RHDOMAINNAME=$domainName --privileged -v /dev/bus/usb:/dev/bus/usb -i -t redhawk-usrp-uhd bash -l -c "uhd_find_devices && nodeBooter -d \$SDRROOT/dev/nodes/usrpNode_\$RHUSRPNAME\$USRP_ID/DeviceManager.dcd.xml"


