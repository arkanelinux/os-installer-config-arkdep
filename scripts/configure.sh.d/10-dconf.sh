declare -r deployment=($(ls $workdir/arkdep/deployments/))

sudo dconf compile $workdir/arkdep/overlay/etc/dconf/db/local \
	$workdir/arkdep/deployments/${deployment[0]}/rootfs/etc/dconf/db/local.d/ ||
	quit_on_err 'Failed to generate local dconf database'

sudo cp $workdir/arkdep/overlay/etc/dconf/db/local \
	$workdir/arkdep/deployments/${deployment[0]}/rootfs/etc/dconf/db/local ||
	quit_on_err 'Failed to copy dconf local db to deployment'
