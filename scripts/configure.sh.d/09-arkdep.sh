# Deploy latest image
sudo arch-chroot $workdir arkdep deploy || quit_on_err 'Failed to deploy image with arkdep'

# Copy previously generated locale over
sudo cp -v $workdir/usr/lib/locale/locale-archive $workdir/arkdep/shared/var/usrliblocale/ \
	|| quit_on_err 'Failed to copy locale-archive to usrliblocale'

# Collect information about the system memory, this is used to determine an apropriate swapfile size
declare -ri memtotal=$(grep MemTotal /proc/meminfo | awk '{print $2}')

# Determine suitable swapfile size
if [[ $memtotal -lt 4500000 ]]; then
	# If RAM is less than 4.5GB create a 2GB swapfile
	sudo arch-chroot $workdir btrfs filesystem mkswapfile --size 2G /arkdep/shared/var/swapfile \
		|| quit_on_err 'Failed to create swapfile'
elif [[ $memtotal -lt 8500000 ]]; then
	# If RAM is less than 8.5GB, create a 4GB swapfile
	sudo arch-chroot $workdir btrfs filesystem mkswapfile --size 4G /arkdep/shared/var/swapfile \
		|| quit_on_err 'Failed to create swapfile'
else
	# Else create a 6GB swapfile
	sudo arch-chroot $workdir btrfs filesystem mkswapfile --size 6G /arkdep/shared/var/swapfile \
		|| quit_on_err 'Failed to create swapfile'
fi
