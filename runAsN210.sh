#!/bin/bash
#
# This file is protected by Copyright. Please refer to the COPYRIGHT file
# distributed with this source distribution.
#
# This file is part of REDHAWK rest-python.
#
# REDHAWK rest-python is free software: you can redistribute it and/or modify it under
# the terms of the GNU Lesser General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# REDHAWK rest-python is distributed in the hope that it will be useful, but WITHOUT
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

# Check if the IP addresses are provided
if [ "$1" == "" ]; then
	echo "The IP address of the Domain Manager must be provided"
	exit 1
fi

if [ "$2" == "" ]; then
	echo "The IP address of the N210 must be provided"
	exit 1
fi

# Check if a Domain Manager is provided
domainName="$3"

if [ "$3" == "" ]; then
	domainName="REDHAWK_DEV"
fi

# Run the docker container as an N210 host
docker run --net=host -e OMNISERVICEIP=$1 -e RHUSRPARGS="--usrpip=$2" -e RHUSRPNAME="N210_" -e RHDOMAINNAME=$domainName -i -t redhawk-usrp-uhd bash -l -c "nodeBooter -d \$SDRROOT/dev/nodes/usrpNode_\$RHUSRPNAME\$USRP_ID/DeviceManager.dcd.xml"
