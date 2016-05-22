#!/bin/bash

install system-config/99-usrp-b205.rules /etc/udev/rules.d
install system-config/redhawk-usrp-uhd-b205 /etc/init.d
install system-config/redhawk-usrp-uhd-n210-watcher /etc/init.d
install system-config/redhawk-usrp-uhd-n210-watcher.py /usr/bin/redhawk-usrp-uhd-n210-watcher
install runAsB2XX.sh /usr/bin/redhawk-usrp-uhd-b205
install runAsN210.sh /usr/bin/redhawk-usrp-uhd-n210
mkdir -p /var/log/redhawk-usrp-uhd-b205
mkdir -p /var/log/redhawk-usrp-uhd-n210-watcher

udevadm control --reload-rules
