# Set custom keymap, very hacky but it gets the job done
# TODO: Also set in TTY
declare -r current_keymap=$(gsettings get org.gnome.desktop.input-sources sources)
sudo mkdir -p $workdir/arkdep/overlay/etc/dconf/db/local.d
printf "[org/gnome/desktop/input-sources]\nsources = $current_keymap\n" |
	sudo tee $workdir/arkdep/overlay/etc/dconf/db/local.d/keymap ||
	quit_on_err 'Failed to set dconf keymap'
