# Bootstrap packages to the new root
# Retry installing three times before quitting
for n in {1..3}; do
	sudo pacstrap $workdir ${base_packages[*]}
	exit_code=$?

	if [[ $exit_code == 0 ]]; then
		break
	else
		if [[ $n == 3 ]]; then
			quit_on_err 'Failed pacstrap after 3 retries'
		fi
	fi
done

# Copy the ISO's pacman.conf file to the new installation
grep -v 'localrepo' /etc/pacman.conf \
	| sudo tee $workdir/etc/pacman.conf \
	|| quit_on_err 'Failed to copy local pacman.conf to new root'

# For some reason Arch does not populate the keyring upon installing
# arkane-keyring, thus we have to populate it manually
sudo arch-chroot $workdir pacman-key --populate arkane \
	|| quit_on_err 'Failed to populate pacman keyring with Arkane keys'
