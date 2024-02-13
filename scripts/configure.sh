#!/usr/bin/env bash

set -o pipefail

## Set common variables
#
# Commonly used variables
declare -r workdir='/mnt'
declare -r osidir='/etc/os-installer'

# Get target disk UUID
declare -r uuid=$(sudo blkid -o value -s UUID ${OSI_DEVICE_PATH}2)

# User can provide full name as input, if they do only the first word will be used as username
# OSI_USER_NAME is still used in the account comments
declare firstname=($OSI_USER_NAME)
firstname=${firstname[0]}

## Set common functions
#
# Quit script with error if called
quit_on_err () {
	if [[ -n $1 ]]; then
		printf "$1\n"
	fi

	# Ensure console prints error
	sleep 2

	exit 1
}

## Execute scripts
#
# Get list of all child scripts
declare -r scripts=($(ls $scriptsdir))

# Loop and run install scripts
for script in ${scripts[@]}; do
	print "Now running $script\n"
	source $scriptsdir/$script
done

## Cleanup and finish
#
# Ensure synced and umount
sync
sudo umount -R /mnt

exit 0
