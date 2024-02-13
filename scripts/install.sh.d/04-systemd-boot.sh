# Install the systemd-boot bootloader
sudo arch-chroot $workdir bootctl install \
	|| quit_on_err 'Failed to install systemd-boot'
