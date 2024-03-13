# Initialize arkdep
sudo ARKDEP_NO_BOOTCTL=1 ARKDEP_ROOT="$workdir" arkdep init \
	|| quit_on_err 'Failed to init arkep'
