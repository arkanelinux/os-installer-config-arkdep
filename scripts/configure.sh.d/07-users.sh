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
sudo arch-chroot $workdir mkdir -p "/arkdep/shared/home/${firstname,,}" || quit_on_err 'Failed to create userhome on arkdep home subvolume'
sudo arch-chroot $workdir cp -r /etc/skel/. "/arkdep/shared/home/${firstname,,}" || quit_on_err 'Failed to copy skel to userhome'
sudo arch-chroot $workdir chown -R "${firstname,,}:${firstname,,}" "/arkdep/shared/home/${firstname,,}" || quit_on_err 'Failed to change userhome ownership permissions'

