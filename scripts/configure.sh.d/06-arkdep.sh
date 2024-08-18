# Deploy latest image
sudo ARKDEP_NO_BOOTCTL=1 ARKDEP_ROOT=$workdir arkdep deploy || quit_on_err 'Failed to deploy image with arkdep'

declare -r deployment_version=($(ls $workdir/arkdep/deployments))

# Collect information about the system memory, this is used to determine an apropriate swapfile size
declare -ri memtotal=$(grep MemTotal /proc/meminfo | awk '{print $2}')

# Determine suitable swapfile size
if [[ $memtotal -lt 4500000 ]]; then
	# If RAM is less than 4.5GB create a 2GB swapfile
	sudo btrfs filesystem mkswapfile --size 2G $workdir/arkdep/shared/swapfile ||
		quit_on_err 'Failed to create swapfile'
elif [[ $memtotal -lt 8500000 ]]; then
	# If RAM is less than 8.5GB, create a 4GB swapfile
	sudo btrfs filesystem mkswapfile --size 4G $workdir/arkdep/shared/swapfile ||
		quit_on_err 'Failed to create swapfile'
else
	# Else create a 6GB swapfile
	sudo btrfs filesystem mkswapfile --size 6G $workdir/arkdep/shared/swapfile ||
		quit_on_err 'Failed to create swapfile'
fi
