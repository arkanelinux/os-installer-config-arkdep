# Write partition table to the disk unless manual partitioning is used
if [[ $OSI_DEVICE_IS_PARTITION -eq 0 ]]; then
	sudo sfdisk $OSI_DEVICE_PATH < $osidir/bits/part.sfdisk ||
		quit_on_err 'Failed to write partition table to disk'
fi

# NVMe drives follow a slightly different naming scheme to other block devices
# this will change `/dev/nvme0n1` to `/dev/nvme0n1p` for easier parsing later
if [[ $OSI_DEVICE_PATH == *"nvme"*"n"* ]]; then
	declare -r partition_path="${OSI_DEVICE_PATH}p"
else
	declare -r partition_path="${OSI_DEVICE_PATH}"
fi

# Check if encryption is requested, write filesystems accordingly
if [[ $OSI_USE_ENCRYPTION -eq 1 ]]; then

	# If user requested disk encryption
	if [[ $OSI_DEVICE_IS_PARTITION -eq 0 ]]; then
		# If target is a drive
		sudo mkfs.fat -F32 ${partition_path}1 || quit_on_err "Failed to create FAT filesystem on ${partition_path}1"
		echo $OSI_ENCRYPTION_PIN | sudo cryptsetup -q luksFormat ${partition_path}2 ||
			quit_on_err "Failed to create LUKS partition on ${partition_path}2"

		echo $OSI_ENCRYPTION_PIN | sudo cryptsetup open ${partition_path}2 $rootlabel - ||
			quit_on_err 'Failed to unlock LUKS partition'

		sudo mkfs.btrfs -f -L $rootlabel /dev/mapper/$rootlabel ||
			quit_on_err 'Failed to create Btrfs partition on LUKS'

		sudo mount -o compress=zstd /dev/mapper/$rootlabel $workdir ||
			quit_on_err "Failed to mount LUKS/Btrfs root partition to $workdir"

		sudo mount --mkdir ${partition_path}1 $workdir/boot ||
			quit_on_err 'Failed to mount boot'
	else
		# If target is a partition
		sudo mkfs.fat -F32 $OSI_DEVICE_EFI_PARTITION ||
			quit_on_err "Failed to create FAT filesystem on $OSI_DEVICE_EFI_PARTITION"

		echo $OSI_ENCRYPTION_PIN | sudo cryptsetup -q luksFormat $OSI_DEVICE_PATH ||
			quit_on_err "Failed to create LUKS partition on $OSI_DEVICE_PATH"

		echo $OSI_ENCRYPTION_PIN | sudo cryptsetup open $OSI_DEVICE_PATH $rootlabel - ||
			quit_on_err 'Failed to unlock LUKS partition'

		sudo mkfs.btrfs -f -L $rootlabel /dev/mapper/$rootlabel ||
			quit_on_err 'Failed to create Btrfs partition on LUKS'

		sudo mount -o compress=zstd /dev/mapper/$rootlabel $workdir ||
			quit_on_err "Failed to mount LUKS/Btrfs root partition to $workdir"

		sudo mount --mkdir $OSI_DEVICE_EFI_PARTITION $workdir/boot ||
			quit_on_err 'Failed to mount boot'
	fi

else

	# If no disk encryption requested
	if [[ $OSI_DEVICE_IS_PARTITION -eq 0 ]]; then
		# If target is a drive
		sudo mkfs.fat -F32 ${partition_path}1 ||
			quit_on_err "Failed to create FAT filesystem on ${partition_path}1"

		sudo mkfs.btrfs -f -L $rootlabel ${partition_path}2 ||
			quit_on_err "Failed to create root on ${partition_path}2"

		sudo mount -o compress=zstd ${partition_path}2 $workdir ||
			quit_on_err "Failed to mount root to $workdir"

		sudo mount --mkdir ${partition_path}1 $workdir/boot ||
			quit_on_err 'Failed to mount boot'
	else
		# If target is a partition
		sudo mkfs.fat -F32 $OSI_DEVICE_EFI_PARTITION ||
			quit_on_err "Failed to create FAT filesystem on $OSI_EFI_PARTITION"

		sudo mkfs.btrfs -f -L $rootlabel $OSI_DEVICE_PATH ||
			quit_on_err "Failed to create root on $OSI_DEVICE_PATH"

		sudo mount -o compress=zstd $OSI_DEVICE_PATH $workdir ||
			quit_on_err "Failed to mount root to $workdir"

		sudo mount --mkdir $OSI_DEVICE_EFI_PARTITION $workdir/boot ||
			quit_on_err 'Failed to mount boot'
	fi

fi

# Ensure partitions are mounted, quit and error if not
for mountpoint in $workdir $workdir/boot; do
	mountpoint -q $mountpoint ||
		quit_on_err "No volume mounted to $mountpoint"
done
