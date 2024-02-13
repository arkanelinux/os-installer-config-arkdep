# Set auto login if requested
if [[ $OSI_USER_AUTOLOGIN -eq 1 ]]; then
	sudo mkdir -p $workdir/arkdep/overlay/etc/gdm/
	printf "[daemon]\nAutomaticLoginEnable=True\nAutomaticLogin=${firstname,,}\n" | sudo tee $workdir/arkdep/overlay/etc/gdm/custom.conf || quit_on_err 'Failed to setup automatic login for user'
fi
