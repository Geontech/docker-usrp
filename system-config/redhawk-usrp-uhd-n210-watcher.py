#!/usr/bin/python -u

import errno
import os
import re
import signal
import subprocess
import sys
import time

from optparse import OptionParser

# Return a set of all USRP2 devices
def getN210s():
	p = subprocess.Popen(["uhd_find_devices", "--args='type=usrp2'"], stdout=subprocess.PIPE)
	out, err = p.communicate()

	if err != None:
		return {}

	prog = re.compile(r'addr: ([^\n]+)\n    name: [^\n]*\n    serial: ([^\n]+)\n')

	matches = prog.findall(out)

	# Each item is a tuple of (IP Address, Serial ID)
	n210s = set(matches)
		
	return n210s

# Close all of the N210s
def closeN210s():
	for item in currentN210s.itervalues():
		print "Sending SIGINT to " + item['info'][1]
		item['process'].send_signal(signal.SIGINT)

	print "Sent all signals, waiting..."

	for item in currentN210s.itervalues():
		item['process'].wait()

	print "All processes stopped, closing log file..."

	for item in currentN210s.itervalues():
		if item.has_key('logfile'):
			print "Closing " + item['info'][1] + " log file"
			item['logfile'].close()

if __name__ == "__main__":
	# Capture CLAs
	parser = OptionParser()

        parser.add_option("-d", "--domain", dest="domain", help="Domain Manager Name", default="REDHAWK_DEV")
	parser.add_option("-i", "--omniIp", dest="omniIp", help="Omni IP Address", default="127.0.0.1")
	parser.add_option("-l", "--logdir", dest="logdir", help="The log directory", default="/var/log/redhawk-usrp-uhd-n210-watcher")
	parser.add_option("-p", "--period", dest="period", help="The update period", default=5)

	(options, args) = parser.parse_args()

	domain = options.domain
	omniIp = options.omniIp
	logdir = options.logdir
	period = options.period

	# Create the logdir
	logdirExists = None

	try:
		os.mkdir(logdir)
		logdirExists = True
	except OSError as e:
		if e.errno != errno.EEXIST:
			print e
			logdirExists = False
		else:
			logdirExists = True

	# Open up devnull
	FNULL = open(os.devnull, 'w')

	# The list of N210s currently controlled by this script
	currentN210s = dict()

	# The signal handler to stop the N210s
	def cleanUp(sig, frame):
		print "Received Termination Signal"
		closeN210s()
		FNULL.close()

		sys.exit(0)
	
	# Assign the signal handler to SIGINT
	signal.signal(signal.SIGINT, cleanUp)
	signal.signal(signal.SIGTERM, cleanUp)

	oldSet = set()

	# The main program loop
	while True:
		newSet = getN210s()

		# Figure out which N210s were added and removed
		added = newSet - oldSet
		removed = oldSet - newSet

		# Iterate over all removed N210s, kill their containers, and remove them from the current dict
		for r in removed:
			ip = r[0]
			serial = r[1]

			if currentN210s.has_key(ip):
				item = currentN210s[ip]
				print "Sending SIGINT to " + serial
				item['process'].send_signal(signal.SIGINT)
				item['process'].wait()

				if item.has_key('logfile'):
					item['logfile'].close()
					print "Closing " + serial + " log file"

				del currentN210s[ip]

		# Iterate over all added N210s, launch their containers, and add them to the current dict
		for a in added:
			ip = a[0]
			serial = a[1]

			if not currentN210s.has_key(ip):
				item = dict()
				item['info'] = a

				print "Starting " + serial + " container"
				
				if logdirExists:
					print "Creating " + serial + " log file"
	                                item['logfile'] = open(logdir + '/' + serial, 'w')
					item['process'] = subprocess.Popen(['/usr/bin/redhawk-usrp-uhd-n210 -i ' + omniIp + ' -u ' + ip + ' -n -d ' + domain], stdout=item['logfile'], stderr=subprocess.STDOUT, shell=True)
				else:
					item['process'] = subprocess.Popen(['/usr/bin/redhawk-usrp-uhd-n210 -i ' + omniIp + ' -u ' + ip + ' -n -d ' + domain], stdout=FNULL, stderr=subprocess.STDOUT, shell=True)

				currentN210s[ip] = item

		# Sleep for the specified amount of time
		time.sleep(period)

		oldSet = newSet

	closeN210s()
	FNULL.close()
