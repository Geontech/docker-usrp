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
FROM redhawk-base
MAINTAINER Thomas Goodwin <btgoodwin@geontech.com>
LABEL version="1.0" description="CentOS 6 with REDHAWK 2 compiled from source against Boost 1.56, UHD 3.10, and the USRP_UHD Device installed with a Node"

# Load other dependencies
RUN yum update -y && \
    yum install -y \
        bzip2-devel \
        cmake \
        doxygen \
        libusb1-devel \
        openssl-devel \
        python-docutils \
        sqlite-devel \
        zlib-devel

# Co-install python 2.7.6
RUN wget http://www.python.org/ftp/python/2.7.6/Python-2.7.6.tar.xz && \
    tar xvfJ Python-2.7.6.tar.xz && \
    cd Python-2.7.6 && \
    ./configure && \
    make && \
    make altinstall && \
    cd .. && \
    rm -rf Python-2.7.6

# Install setuptools and pip for python 2.7.6
RUN wget --no-check-certificate https://pypi.python.org/packages/source/s/setuptools/setuptools-1.4.2.tar.gz && \
    tar -xvf setuptools-1.4.2.tar.gz && \
    cd setuptools-1.4.2 && \
    python2.7 setup.py install && \
    cd .. && \
    rm -rf setuptools-1.4.2 && \
    curl https://bootstrap.pypa.io/get-pip.py | python2.7 - && \
    rm -rf get-pip.py

# Prepare the UHD dependencies
RUN pip2.7 install --upgrade pip
RUN pip2.7 install --upgrade mako
RUN pip2.7 install --upgrade requests

# Modify PYTHONPATH to reflect the python 2.7.6 site packages
ENV PYTHONPATH /usr/local/lib/python2.7/site-packages:${PYTHONPATH}

# UHD Driver
RUN git clone git://github.com/EttusResearch/uhd.git && \
    mkdir -p uhd/host/build && \
    cd uhd/host/build && \
    cmake ../ -DPYTHON_EXECUTABLE=/usr/local/bin/python2.7 && \
    make \
        LDFLAGS=${LDFLAGS} \
        CPPFLAGS=${CPPFLAGS} \
        PATH=/usr/local/bin:${PATH} && \
    make test && \
    make install && \
    cd ../../.. && \
    rm -rf uhd && \
    ldconfig

# USRP UHD Device
RUN git clone git://github.com/RedhawkSDR/USRP_UHD.git && \
    cd USRP_UHD && \
    git checkout tags/4.0.0 && \
    mkdir src && touch src/AUTHORS src/ChangeLog src/NEWS src/README && \
    sed -i 's/get_props/get_simple/g' nodeconfig.py && \
    cd cpp && \
    ./reconf && \
    ./configure \
        --with-ossie=${OSSIEHOME} \
        --with-sdr=${SDRROOT} \
        LDFLAGS=${LDFLAGS} \
        CPPFLAGS=${CPPFLAGS} \
        PYTHONPATH=${PYTHONPATH} \
        --with-boost=/usr/local \
        --with-boost-libdir=/usr/local/lib && \
    make && \
    make install && \
    cd ../.. && \
    rm -rf USRP_UHD

# Create a unique ID for the node
RUN echo 'export USRP_ID=$(uuidgen)' | tee -a /root/.bashrc

# Add a call to nodeconfig in the /root/.bashrc to generate a node on startup of the container.
RUN echo '${SDRROOT}/dev/devices/rh/USRP_UHD/nodeconfig.py --domainname $RHDOMAINNAME $RHUSRPARGS --nodename=usrpNode_$RHUSRPNAME$USRP_ID' | tee -a /root/.bashrc

# Add a call to uhd_images_downloader in the /root/.bashrc to download the latest images
RUN echo '/usr/local/lib64/uhd/utils/uhd_images_downloader.py' | tee -a /root/.bashrc

# Copy the non-interactive script
COPY nonInteractive.sh /

# Delete the build area
WORKDIR /
RUN rm -rf /tmp

# Expose omni's ports
EXPOSE 2809
EXPOSE 11169

CMD ["/nonInteractive.sh"]
