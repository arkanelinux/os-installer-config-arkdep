#!/usr/bin/env bash

set -o pipefail

## Generic checks
#
# Ensure user is in sudo group
for group in $(groups); do

	if [[ $group == 'wheel' || $group == 'sudo' ]]; then
		declare -ri sudo_ok=1
	fi

done

# If user is not in sudo group notify and exit with error
if [[ ! -n $sudo_ok ]]; then
	printf 'The current user is not a member of either the sudo or wheel group, this os-installer configuration requires sudo permissions\n'
	exit 1
fi

# Function used to quit and notify user or error
quit_on_err () {
	if [[ -v $1 ]]; then
		printf '$1\n'
	fi

	# Ensure the terminal has time to print before exiting
	sleep 2

	exit 1
}

## Pre-run checks to ensure everything is ready
#
# Ensure we are able to connect with the image repo
printf 'Checking for connectivity to the image repository... '
wget -P /home/arkane/ https://repo.arkanelinux.org/ || quit_on_err 'Failed to connect with Arkane repositories'

exit 0
