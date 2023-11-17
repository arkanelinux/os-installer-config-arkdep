#!/usr/bin/env bash

set -o pipefail

declare -r workdir='/mnt'
declare -r osidir='/etc/os-installer'

## Generic checks
#
# Ensure user is in sudo group
for group in $(groups); do

	if [[ $group == 'wheel' || $group == 'sudo' ]]; then
		declare -ri sudo_ok=1
	fi

done

# If user is not in sudo group notify and exit with error
if [[ ! -n $sudo_ok ]]; then
	printf 'The current user is not a member of either the sudo or wheel group, this os-installer configuration requires sudo permissions\n'
	exit 1
fi

# Function used to quit and notify user or error
quit_on_err () {
	if [[ -n $1 ]]; then
		printf "$1\n"
	fi

	# Ensure console prints error
	sleep 2

	exit 1
}

# sanity check that all variables were set
[[ -z ${OSI_LOCALE+x} ]] && quit_on_err 'OSI_LOCALE not set'
#[[ -z ${OSI_KEYBOARD_LAYOUT+x} ]] && quit_on_err 'OSI_KEYBOARD_LAYOUT not set' --- Disabled due to OSI bug
[[ -z ${OSI_DEVICE_PATH+x} ]] && quit_on_err 'OSI_DEVICE_PATH not set'
[[ -z ${OSI_DEVICE_IS_PARTITION+x} ]] && quit_on_err 'OSI_DEVICE_OS_PARTITION is not set'
[[ -z ${OSI_DEVICE_EFI_PARTITION+x} ]] && quit_on_err 'OSI_DEVICE_EFI_PARTITION is not set'
[[ -z ${OSI_USE_ENCRYPTION+x} ]] && quit_on_err 'OSI_USE_ENCRYPTION is not set'
[[ -z ${OSI_ENCRYPTION_PIN+x} ]] && quit_on_err 'OSI_ENCRYPT_PIN is not set'
[[ -z ${OSI_USER_NAME+x} ]] && quit_on_err 'OSI_USER_NAME is not set'
[[ -z ${OSI_USER_AUTOLOGIN+x} ]] && quit_on_err 'OSI_USER_AUTOLOGIN is not set'
[[ -z ${OSI_USER_PASSWORD+x} ]] && quit_on_err 'OSI_USER_PASSWORD is not set'
[[ -z ${OSI_FORMATS+x} ]] && quit_on_err 'OSI_FORMATS is not set'
[[ -z ${OSI_TIMEZONE+x} ]] && quit_on_err 'OSI_TIMEZONE is not set'
[[ -z ${OSI_ADDITIONAL_SOFTWARE+x} ]] && quit_on_err 'OSI_ADDITIONAL_SOFTWARE is not set'
[[ -z ${OSI_ADDITIONAL_FEATURES+x} ]] && quit_on_err 'OSI_ADDITIONAL_FEATURES is not set'

# Generate the fstab file for fallback
genfstab $workdir >> sudo tee $workdir/etc/fstab

## Perpare for arkep deployment
#
# Copy overlay to new root
for f in $(ls $osidir/overlay/); do
	sudo cp -rv $osidir/overlay/$f $workdir/ || quit_on_err 'Failed to copy overlay to workdir'
done

# Write overlay_arkdep
for f in $(ls $osidir/overlay_arkdep/); do
	sudo cp -rv $osidir/overlay_arkdep/$f $workdir/arkdep/overlay/
done

# Update fstab with /boot config
grep '/boot' $workdir/etc/fstab >> $workdir/arkdep/overlay/etc/fstab

# Ensure etc exists in arkdep overlay, it should already, but lets make sure anyway
sudo mkdir $workdir/arkdep/overlay/etc

## Locale and timezone
#
# Set chosen locale and en_US.UTF-8
echo "$OSI_LOCALE UTF-8" | sudo tee -a $workdir/etc/locale.gen $workdir/arkdep/overlay/etc/locale.gen || quit_on_err 'Failed to configure locale.gen'

if [[ $OSI_LOCALE != 'en_US.UTF-8' ]]; then
	echo "en_US.UTF-8 UTF-8" | sudo tee -a $workdir/etc/locale.gen $workdir/arkdep/overlay/etc/locale.gen || quit_on_err 'Failed to configure locale.gen with en_US.UTF-8'
fi

echo "LANG=\"$OSI_LOCALE\"" | sudo tee $workdir/etc/locale.conf $workdir/arkdep/overlay/etc/locale.conf || quit_on_err 'Failed to set default locale'

# Set timezome
sudo ln -sf /usr/share/zoneinfo/$OSI_TIMEZONE $workdir/etc/localtime || quit_on_err 'Failed to set timezone'
sudo ln -sf /usr/share/zoneinfo/$OSI_TIMEZONE $workdir/arkdep/overlay/etc/localtime || quit_on_err 'Failed to set timezone in arkdep overlay'

# Generate locales
sudo arch-chroot $workdir locale-gen || quit_on_err 'Failed to locale-gen'

# Set kernel parameters in Systemd-boot based on if disk encryption is used or not
# This is the base string shared by all configurations
declare -r kernel_params='lsm=landlock,lockdown,yama,integrity,apparmor,bpf quiet splash loglevel=3 vt.global_cursor_default=0 systemd.show_status=auto rd.udev.log_level=3 rw'

# The kernel parameters have to be configured differently based upon if the
# user opted for disk encryption or not
if [[ $OSI_USE_ENCRYPTION == 1 ]]; then
	# Get drive UUID
	declare -r uuid=$(sudo blkid -o value -s UUID ${OSI_DEVICE_PATH}2)

	# Overwrite default systemd-boot template
	cat <<- END > $workdir/arkdep/templates/systemd-boot
	title Arkane GNU/Linux - arkdep
	linux /arkdep/%target%/vmlinuz
	initrd /amd-ucode.img
	initrd /intel-ucode.img
	initrd /arkdep/%target%/initramfs-linux.img
	options rd.luks.name=$uuid=arkane_root root=/dev/mapper/arkane_root rootflags=subvol=/arkdep/deployments/%target%/rootfs lsm=landlock,lockdown,yama,integrity,apparmor,bpf quiet splash loglevel=3 vt.global_cursor_default=0 systemd.show_status=auto rd.udev.log_level=3 rw
	END

	echo "options rd.luks.name=$uuid=arkane_root root=/dev/mapper/arkane_root $kernel_params" | sudo tee -a $workdir/boot/loader/entries/arkane.conf || quit_on_err 'Failed to configure bootloader config'
	echo "options rd.luks.name=$uuid=arkane_root root=/dev/mapper/arkane_root $kernel_params" | sudo tee -a $workdir/boot/loader/entries/arkane-fallback.conf || quit_on_err 'Failed to configure bootloader fallback config'

	sudo sed -i '/^#/!s/HOOKS=(.*)/HOOKS=(systemd sd-plymouth autodetect keyboard keymap consolefont modconf block sd-encrypt filesystems fsck)/g' $workdir/etc/mkinitcpio.conf || quit_on_err 'Failed to set hooks'
	sudo arch-chroot $workdir mkinitcpio -P || quit_on_err 'Failed to mkinitcpio'
else
	# Overwrite default systemd-boot template
	cat <<- END | sudo tee $workdir/arkdep/templates/systemd-boot
	title Arkane GNU/Linux - arkdep
	linux /arkdep/%target%/vmlinuz
	initrd /amd-ucode.img
	initrd /intel-ucode.img
	initrd /arkdep/%target%/initramfs-linux.img
	options root="LABEL=arkane_root" rootflags=subvol=/arkdep/deployments/%target%/rootfs lsm=landlock,lockdown,yama,integrity,apparmor,bpf quiet splash loglevel=3 vt.global_cursor_default=0 systemd.show_status=auto rd.udev.log_level=3 rw
	END

	echo "options root=\"LABEL=arkane_root\" $kernel_params" | sudo tee -a $workdir/boot/loader/entries/arkane.conf
	echo "options root=\"LABEL=arkane_root\" $kernel_params" | sudo tee -a $workdir/boot/loader/entries/arkane-fallback.conf

	sudo sed -i '/^#/!s/HOOKS=(.*)/HOOKS=(systemd sd-plymouth autodetect keyboard keymap consolefont modconf block filesystems fsck)/g' $workdir/etc/mkinitcpio.conf || quit_on_err 'Failed to set hooks'
	sudo arch-chroot $workdir mkinitcpio -P || quit_on_err 'Failed to generate initramfs'
fi


# Set custom keymap, very hacky but it gets the job done
# TODO: Also set in TTY
declare -r current_keymap=$(gsettings get org.gnome.desktop.input-sources sources)
sudo mkdir -p $workdir/arkdep/overlay/etc/dconf/db/local.d
printf "[org.gnome.desktop.input-sources]\nsources = $current_keymap\n" | sudo tee $workdir/arkdep/overlay/etc/dconf/db/local.d/keymap || quit_on_err 'Failed to set dconf keymap'

# Set auto login if requested
if [[ $OSI_USER_AUTOLOGIN -eq 1 ]]; then
	sudo mkdir -p $workdir/arkdep/overlay/etc/gdm/
	printf "[daemon]\nAutomaticLoginEnable=True\nAutomaticLogin=${firstname,,}\n" | sudo tee $workdir/arkdep/overlay/etc/gdm/custom.conf || quit_on_err 'Failed to setup automatic login for user'
fi

## Add user accounts
#
# Get first name
declare firstname=($OSI_USER_NAME)
firstname=${firstname[0]}

# Add user, setup groups and set password
sudo arch-chroot $workdir useradd -m  -c "$OSI_USER_NAME" "${firstname,,}" || quit_on_err 'Failed to add user'
echo "${firstname,,}:$OSI_USER_PASSWORD" | sudo arch-chroot $workdir chpasswd || quit_on_err 'Failed to set user password'
sudo arch-chroot $workdir usermod -a -G wheel "${firstname,,}" || quit_on_err 'Failed to make user sudoer'

# Set root password
echo "root:$OSI_USER_PASSWORD" | sudo arch-chroot $workdir chpasswd || quit_on_err 'Failed to set root password'

# Add non-system user accounts to overlay
sudo grep "^${firstname,,}\|^root" $workdir/etc/passwd | sudo tee $workdir/arkdep/overlay/etc/passwd || quit_on_err 'Failed to write passwd to overlay'
sudo grep "^${firstname,,}\|^root" $workdir/etc/shadow | sudo tee $workdir/arkdep/overlay/etc/shadow || quit_on_err 'Failed to write shadow to overlay'
sudo grep "^${firstname,,}\|^root\|^wheel" $workdir/etc/group | sudo tee $workdir/arkdep/overlay/etc/group || quit_on_err 'Failed to write group to overlay'
sudo cp -v $workdir/etc/{subgid,subuid} $workdir/arkdep/overlay/etc/ || quit_on_err 'Failed to copy subgid and subuid to overlay'

# Prep user homedir
sudo arch-chroot $workdir mkhomedir_helper "${firstname,,}"

## Arkdep deployment
#
# Deploy latest image
sudo arch-chroot $workdir arkdep deploy || quit_on_err 'Failed to deploy image with arkdep'

## arkdep /var setup
#
# Copy previously generated locale over
sudo cp -v $workdir/usr/lib/locale/locale-archive $workdir/arkdep/shared/var/usrliblocale/ || quit_on_err 'Failed to copy locale-archive to usrliblocale'

# Collect information about the system memory, this is used to determine an apropriate swapfile size
declare -ri memtotal=$(grep MemTotal /proc/meminfo | awk '{print $2}')

# Determine suitable swapfile size
if [[ $memtotal -lt 4500000 ]]; then

	# If RAM is less than 4.5GB create a 2GB swapfile
	sudo arch-chroot $workdir btrfs filesystem mkswapfile --size 2G /arkdep/shared/var/swapfile || quit_on_err 'Failed to create swapfile'

elif [[ $memtotal -lt 8500000 ]]; then

	# If RAM is less than 8.5GB, create a 4GB swapfile
	sudo arch-chroot $workdir btrfs filesystem mkswapfile --size 4G /arkdep/shared/var/swapfile || quit_on_err 'Failed to create swapfile'

else

	# Else create a 6GB swapfile
	sudo arch-chroot $workdir btrfs filesystem mkswapfile --size 6G /arkdep/shared/var/swapfile || quit_on_err 'Failed to create swapfile'

fi

# Ensure synced and umount
sync
sudo umount -R /mnt

exit 0
