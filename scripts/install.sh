#!/usr/bin/env bash

set -o pipefail

## Set common variables
#
# Commonly used variables
declare -r workdir='/mnt'
declare -r osidir='/etc/os-installer'
declare -r scriptsdir="$osidir/scripts/install.sh.d"
declare -r rootlabel='manjaro_root'
declare -r bootlabel='manjaro_esp'

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
	printf "Now running $script\n"
	source $scriptsdir/$script
done

exit 0
