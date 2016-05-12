# Docker REDHAWK USRP Image

This Docker image is built upon the REDHAWK Base Image and includes UHD 3.10, the rh.USRP_UHD Device, and a startup profile to create the USRP node and start it when a container of this image is launched. 

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

Use this script to run the REDHAWK USRP UHD Image as an N210 host. This script requires the IP address of the Domain Manager to connect to and the IP address of the N210 as an argument. This script optionally accepts a Domain Name for the Device Manager to connect to, which defaults to REDHAWK_DEV.

	./runAsN210 <DomainManager IP Address> <N210 IP Address> [Domain Manager Name]

#### Run as B2XX

Use this script to run the REDHAWK USRP UHD Image as a B2XX host. This script requires the IP address of the Domain Manager to connect to. This script optionally accepts a Domain Name for the Device Manager to connect to, which defaults to REDHAWK_DEV.

	./runAsB2XX <Domain Manager IP Address> [Domain Manager Name]

### Using Docker

Consult the scripts above for examples of how to run the image.
