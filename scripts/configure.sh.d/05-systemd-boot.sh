# The kernel parameters have to be configured differently based upon if the
# user opted for disk encryption or not
if [[ $OSI_USE_ENCRYPTION == 1 ]]; then
	# Overwrite default Arkdep systemd-boot template
	cat <<- END | sudo tee $workdir/arkdep/templates/systemd-boot
	title Manjaro Immutable
	linux /arkdep/%target%/vmlinuz
	initrd /amd-ucode.img
	initrd /intel-ucode.img
	initrd /arkdep/%target%/initramfs-linux.img
	options rd.auto=0 rd.luks.name=$uuid=manjaro_root root=/dev/mapper/manjaro_root rootflags=subvol=/arkdep/deployments/%target%/rootfs quiet splash loglevel=3 systemd.show_status=auto rd.udev.log_level=3 rw
	END
else
	# Overwrite default Arkdep systemd-boot template
	cat <<- END | sudo tee $workdir/arkdep/templates/systemd-boot
	title Manjaro Immutable
	linux /arkdep/%target%/vmlinuz
	initrd /amd-ucode.img
	initrd /intel-ucode.img
	initrd /arkdep/%target%/initramfs-linux.img
	options root="LABEL=manjaro_root" rootflags=subvol=/arkdep/deployments/%target%/rootfs quiet splash loglevel=3 systemd.show_status=auto rd.udev.log_level=3 rw
	END
fi
