# Set custom keymap, very hacky but it gets the job done
declare -r current_keymap=$(gsettings get org.gnome.desktop.input-sources sources)
sudo mkdir -p $workdir/arkdep/overlay/etc/dconf/db/local.d
printf "[org/gnome/desktop/input-sources]\nsources = $current_keymap\n" |
	sudo tee $workdir/arkdep/overlay/etc/dconf/db/local.d/keymap ||
	quit_on_err 'Failed to set dconf keymap'

# Attempt to set vconsole keymap
data=${current_keymap#*(}
data=${data%%)*}
data=${data#*,}
data=${data//\'}
data=${data%%+*}

sudo localectl set-keymap $data
localctl_exit_code=$?

[[ $localctl_exit_code -ne 0 ]] && printf 'Failed to detect keymap, vconsole will default to US international'
[[ $localctl_exit_code -eq 0 ]] && sudo cp /etc/vconsole.conf $workdir/arkdep/overlay/etc/vconsole.conf
