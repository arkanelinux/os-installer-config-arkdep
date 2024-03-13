# Manually install the systemd-boot bootloader
sudo mkdir -p $workdir/boot/EFI/{BOOT,systemd} \
	$workdir/boot/loader/entries || quit_on_err 'Failed to create bootloader directories'

# TODO: Grab this from the image instead?
sudo cp /usr/lib/systemd/boot/efi/systemd-bootx64.efi \
		$workdir/boot/EFI/systemd/ || quit_on_err 'Failed to copy systemd-boot bootloader to systemd-bootx64.efi'

sudo cp /usr/lib/systemd/boot/efi/systemd-bootx64.efi \
		$workdir/boot/EFI/BOOT/BOOTx64.EFI || quit_on_err 'Failed to copy systemd-boot bootloader to BOOTx64.EFI'

printf 'timeout 5\nconsole-mode max\neditor yes\nauto-entries yes\nauto-firmware yes' | \
	sudo tee $workdir/boot/loader/loader.conf || quit_on_err 'Failed to create loader.conf'
