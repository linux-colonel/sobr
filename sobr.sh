#!/bin/bash

# This is the main script.
# Version
VERSION=0.9
# Path to the default config file
CONFIG_FILE=~/.sobr/config
# Get the functions and variables.
. functions.sh
. default-vars

EXIT=0
while getopts ":c:vhd" opt; do
	case $opt in
		c)
			CONFIG_FILE=$OPTARG
			echo $CONFIG_FILE
			;;
		d)
			set -x
			;;
		v)
			echo "S.O.B.R. Secure Offsite Backup with Rsync"
			echo "Version $VERSION"
			EXIT=1
			;;
		h)
			echo "Usage:"
			echo -e "\t sobr [-d]"
			echo -e "\t sobr [-d] [-h] [-v]"
			echo -e "\t sobr [-d] [-c <path-to-config-file>]"
			EXIT=1
			;;
	esac
done

if [ "$EXIT" -eq 1 ]; then
	exit 1
fi

shift $((OPTIND-1))

# Set CONFIG variable to point to the directory that the config file is in.
# This will allow referencing the CONFIG variable in the config file
CONFIG=$(dirname $CONFIG_FILE)
if [ -r $CONFIG_FILE ] && [ -f $CONFIG_FILE ]; then
	. $CONFIG_FILE
else
	echo "Config file at $CONFIG_FILE not found."
	echo "Exiting..."
	exit 1
fi

check 
ret=$?
if [ $ret -ne 0 ]; then
	echo "A required variable is missing.  Check the required variables in config." >&2
	echo "Exiting..." >&2
	exit 1
fi

decrypt
ret=$?
if [ $ret -ne 0 ]; then
	echo "Unable to decrypt remote storage." >&2
	echo "Exiting..." >&2
	lock
	exit 1
fi

sync
ret=$?
if [ $ret -ne 0 ]; then
        echo "Unable to sync files." >&2
        echo "Exiting..." >&2
        lock
        exit 1
fi

lock

exit 0

