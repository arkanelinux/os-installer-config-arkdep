# Write overlay_arkdep
for f in $(ls $osidir/overlay_arkdep/); do
	sudo cp -rv $osidir/overlay_arkdep/$f $workdir/arkdep/overlay/
done

