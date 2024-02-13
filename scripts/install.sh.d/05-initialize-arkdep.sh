# Initialize arkdep
sudo arch-chroot $workdir arkdep init \
	|| quit_on_err 'Failed to init arkep'
