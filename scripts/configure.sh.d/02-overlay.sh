# Copy overlay to new root
for f in $(ls $osidir/overlay/); do
	sudo cp -rv $osidir/overlay/$f $workdir/ || quit_on_err 'Failed to copy overlay to workdir'
done

# Write overlay_arkdep
for f in $(ls $osidir/overlay_arkdep/); do
	sudo cp -rv $osidir/overlay_arkdep/$f $workdir/arkdep/overlay/
done

