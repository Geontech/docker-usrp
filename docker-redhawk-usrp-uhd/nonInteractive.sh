#!/bin/bash -l

# The handler to forward SIGINT to nodeBooter
handler() {
	kill -s SIGINT $PID
}

# This will initialize the firmware if necessary
uhd_find_devices

# Launch the Device Manager in the background and take not of its PID
nodeBooter -d $SDRROOT/dev/nodes/usrpNode_$RHUSRPNAME$USRP_ID/DeviceManager.dcd.xml &

PID=$!

# Trap SIGINT
trap handler SIGINT

# Wait for the Device Manager to exit
wait $PID

# Give the Device Manager a chance to clean up
sleep 1
