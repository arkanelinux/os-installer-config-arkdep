# Set chosen locale and en_US.UTF-8
echo "$OSI_LOCALE UTF-8" | sudo tee -a $workdir/arkdep/overlay/etc/locale.gen \
	|| quit_on_err 'Failed to configure locale.gen'

if [[ $OSI_LOCALE != 'en_US.UTF-8' ]]; then
	echo "en_US.UTF-8 UTF-8" | sudo tee -a $workdir/arkdep/overlay/etc/locale.gen \
		|| quit_on_err 'Failed to configure locale.gen with en_US.UTF-8'
fi

echo "LANG=\"$OSI_LOCALE\"" | sudo tee $workdir/arkdep/overlay/etc/locale.conf \
	|| quit_on_err 'Failed to set default locale'

# Set timezome
sudo ln -sf /usr/share/zoneinfo/$OSI_TIMEZONE $workdir/arkdep/overlay/etc/localtime \
	|| quit_on_err 'Failed to set timezone in arkdep overlay'

# Set custom keymap, very hacky but it gets the job done
# TODO: Also set in TTY
declare -r current_keymap=$(gsettings get org.gnome.desktop.input-sources sources)
sudo mkdir -p $workdir/arkdep/overlay/etc/dconf/db/local.d
printf "[org.gnome.desktop.input-sources]\nsources = $current_keymap\n" | sudo tee $workdir/arkdep/overlay/etc/dconf/db/local.d/keymap || quit_on_err 'Failed to set dconf keymap'
