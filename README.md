# Docker REDHAWK USRP Image

This Docker image is built upon the REDHAWK Base Image and includes UHD 3.10, the rh.USRP_UHD Device, and a startup profile to create the USRP node and start it when a container of this image is launched.

Several system configuration files are also provided.

## Building

### Using the Script

To build the image, use the provided build.sh script:

        ./build.sh

To remove the image:

        ./build.sh clean

### Using Docker

Alternatively, the image can be built from the top level directory manually with:

        docker build --rm -t redhawk-usrp-uhd docker-redhawk-usrp-uhd

### Permissions

Note that it may be necessary to run the above commands as root if you are not part of the 'docker' group.

## Running

### Using the Scripts

#### Run as N210

Use this script to run the REDHAWK USRP UHD Image as an N210 host. This script requires the IP address of the Domain Manager to connect to and the IP address of the N210 as arguments. This script optionally accepts a Domain Name for the Device Manager to connect to, which defaults to REDHAWK_DEV. To run the script non-interactively (e.g., as a service), pass the -n flag. To pass arguments directly to the docker run command, specify them after a '--'.

	./runAsN210 -i <DomainManager IP Address> -u <N210 IP Address> [-d Domain Manager Name] [-n] [-- docker run arguments]

#### Run as B2XX

Use this script to run the REDHAWK USRP UHD Image as a B2XX host. This script requires the IP address of the Domain Manager to connect to as an argument. This script optionally accepts a Domain Name for the Device Manager to connect to, which defaults to REDHAWK_DEV. To run the script non-interactively (e.g., as a service), pass the -n flag. To pass agruments directly to the docker run command, specify them after a '--'.

	./runAsB2XX -i <Domain Manager IP Address> [-d Domain Manager Name] [-n] [-- docker run arguments]

### Using Docker

Consult the scripts above for examples of how to run the image.

## System Configuration

### Installation

To install the system configuration files, use the provided install.sh script:

	./install.sh

This will install several files:

	system-config/99-usrp-b205.rules		Udev rules for starting and stopping the redhawk-usrp-uhd-b205 service when a b205 is added and removed, respectively
	system-config/redhawk-usrp-uhd-b205		The init.d script for the redhawk-usrp-uhd-b205 service which is responsible for calling the runAsB2XX.sh script
	system-config/redhawk-usrp-uhd-n210-watcher 	The init.d script for the redhawk-usrp-uhd-n210-watcher service which is responsible for launching the python script of the same name
	system-config/redhawk-usrp-uhd-n210-watcher.py	The python script responsible for monitoring available n210s and controlling the lifecycles of their containers
	runAsB2XX.sh					The script from above, which will be installed as /usr/bin/redhawk-usrp-uhd-b205 and will launch the b205 redhawk-usrp-uhd container
	runAsN210.sh					The script from above, which will be installed as /usr/bin/redhawk-usrp-uhd-n210 and will launch the n210 redhawk-usrp-uhd container
	
It will also create the log directories (/var/log/redhawk-usrp-uhd-b205 and /var/log/redhawk-usrp-uhd-n210-watcher) and reload the udev rules (udevadm control --reload-rules).

### Notes

The redhawk-usrp-uhd-b205 service only supports a single b205 per host (for now).

### Additional Configuration

The default Omni IP address and Domain Manager name are 127.0.0.1 and REDHAWK_DEV, respectively. To change these, export one or both of the variables in the appropriate /etc/sysconfig file. That is, to change this for the B205, add the export(s) to the /etc/sysconfig/redhawk-usrp-uhd-b205 script. Similarly, for the N210, add the export(s) to the /etc/sysconfig/redhawk-usrp-uhd-n210-watcher script.

An example configuration is given below:

	export OMNISERVICEIP=192.168.1.2
	export RHDOMAINNAME=REDHAWK_DEV_2_0
