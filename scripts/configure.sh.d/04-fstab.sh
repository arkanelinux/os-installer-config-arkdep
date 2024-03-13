# Ensure etc exists in arkdep overlay, it should already, but lets make sure anyway
sudo mkdir $workdir/arkdep/overlay/etc

# Update fstab with /boot config
grep '/boot' $workdir/etc/fstab | sudo tee -a $workdir/arkdep/overlay/etc/fstab
