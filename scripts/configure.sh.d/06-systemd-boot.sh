# The kernel parameters have to be configured differently based upon if the
# user opted for disk encryption or not
if [[ $OSI_USE_ENCRYPTION == 1 ]]; then
	# Overwrite default Arkdep systemd-boot template
	cat <<- END | sudo tee $workdir/arkdep/templates/systemd-boot
	title Arkane GNU/Linux - Arkdep
	linux /arkdep/%target%/vmlinuz
	initrd /amd-ucode.img
	initrd /intel-ucode.img
	initrd /arkdep/%target%/initramfs-linux.img
	options rd.luks.name=$uuid=arkane_root root=/dev/mapper/arkane_root rootflags=subvol=/arkdep/deployments/%target%/rootfs lsm=landlock,lockdown,yama,integrity,apparmor,bpf quiet splash loglevel=3 systemd.show_status=auto rd.udev.log_level=3 rw
	END

	echo "options rd.luks.name=$uuid=arkane_root root=/dev/mapper/arkane_root rw" | sudo tee -a $workdir/boot/loader/entries/arkane-recovery.conf \
		|| quit_on_err 'Failed to configure bootloader config'

	sudo sed -i '/^#/!s/HOOKS=(.*)/HOOKS=(systemd autodetect keyboard keymap consolefont modconf block sd-encrypt filesystems fsck)/g' $workdir/etc/mkinitcpio.conf \
		|| quit_on_err 'Failed to set hooks'
	sudo arch-chroot $workdir mkinitcpio -P \
		|| quit_on_err 'Failed to mkinitcpio'
else
	# Overwrite default Arkdep systemd-boot template
	cat <<- END | sudo tee $workdir/arkdep/templates/systemd-boot
	title Arkane GNU/Linux - Arkdep
	linux /arkdep/%target%/vmlinuz
	initrd /amd-ucode.img
	initrd /intel-ucode.img
	initrd /arkdep/%target%/initramfs-linux.img
	options root="LABEL=arkane_root" rootflags=subvol=/arkdep/deployments/%target%/rootfs lsm=landlock,lockdown,yama,integrity,apparmor,bpf quiet splash loglevel=3 systemd.show_status=auto rd.udev.log_level=3 rw
	END

	echo "options root=\"LABEL=arkane_root\" rw" | sudo tee -a $workdir/boot/loader/entries/arkane.conf

	sudo sed -i '/^#/!s/HOOKS=(.*)/HOOKS=(systemd autodetect keyboard keymap consolefont modconf block filesystems fsck)/g' $workdir/etc/mkinitcpio.conf \
		|| quit_on_err 'Failed to set hooks'
	sudo arch-chroot $workdir mkinitcpio --preset arkanelinux \
		|| quit_on_err 'Failed to generate initramfs'
fi
