# Ensure all relevant files exist
sudo touch $workdir/arkdep/overlay/etc/{passwd,group,shadow} \
	|| quit_on_err 'Failed to create user account files'
sudo chmod -R 600 $workdir/arkdep/overlay/etc/shadow \
	|| quit_on_err 'Failed to set shadow file permissions'

# Add user and root account and group
sudo groupadd -P $workdir/arkdep/overlay -g 0 root \
	|| quit_on_err 'Failed to create root group'
sudo useradd -P $workdir/arkdep/overlay -u 0 -g 0 -G root -d /root root \
	|| quit_on_err 'Failed to create root user'

sudo groupadd -P $workdir/arkdep/overlay -g 1000 ${firstname,,} \
	|| quit_on_err 'Failed to create user group'
sudo useradd -P $workdir/arkdep/overlay -u 1000 -g 1000 -s /usr/bin/zsh -G ${firstname,,} -c "$OSI_USER_NAME" ${firstname,,} \
	|| quit_on_err 'Failed to create user account'

# Set password
printf "root:$OSI_USER_PASSWORD" | sudo chpasswd -P $workdir/arkdep/overlay \
	|| quit_on_err 'Failed to set root password'
printf "${firstname,,}:$OSI_USER_PASSWORD" | sudo chpasswd -P $workdir/arkdep/overlay \
	|| quit_on_err 'Failed to set user password'

# Remove user account file backups
sudo rm -v $workdir/arkdep/overlay/etc/*-

# Prep user homedir
sudo mkdir -p $workdir/arkdep/shared/home/${firstname,,} \
	|| quit_on_err 'Failed to create userhome on arkdep home subvolume'

# Copy skel instead after deploy?
# No need to copy skel to root home, this is done during image building
sudo cp -r /etc/skel/. $workdir/arkdep/shared/home/${firstname,,} \
	|| quit_on_err 'Failed to copy skel to userhome'
sudo chown -R 1000:1000 $workdir/arkdep/shared/home/${firstname,,} \
	|| quit_on_err 'Failed to change userhome ownership permissions'
