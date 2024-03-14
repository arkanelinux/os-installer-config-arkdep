sudo umount -R $workdir/boot

# Remove boot folder, it is just a temporary mount point
sudo rm -rf $workdir/boot

sync
sudo umount -R $workdir
