# Initialize arkdep
sudo ARKDEP_NO_BOOTCTL=1 ARKDEP_ROOT="$workdir" arkdep init ||
	quit_on_err 'Failed to init arkep'

# Add proper config file
cat <<-END | sudo tee $workdir/arkdep/config
# Write /arkdep/overlay overlay to new deployments
enable_overlay=1

# URL to image repository, do not add trailing slash
repo_url='https://download.manjaro.org/arkdep'

# Default image pulled from repo if nothing defined
repo_default_image='test-manjaro-gnome'

# Keep the latest N deployments, remove anything older
deploy_keep=2

# Remove images from the cache when their deployments are removed
clean_cache_on_remove=1

# Check for untracked deployments and other issues on run
always_healthcheck=1

# Perform a GPG signature check on remote sources
# 1 = enabled but optional, 2 = required
gpg_signature_check=1

# Minimum amount of storage which needs to be available on /boot in Kib
minimum_available_boot_storage=153600

# Minimum amount of storage which needs to be available on / in Kib
minimum_available_root_storage=12582912

# Update CPU firmware if newer version available
update_cpu_microcode=1

# Automatically make a copy of passwd, shadow and group files if they differ from overlay
backup_user_accounts=1

# Ensure latest image as defined in the external database is always the default systemd-boot boot entry
latest_image_always_default=0

# List of files and folders to be recursively copied over from root to new root, path should start with /
migrate_files=('/var/usrlocal' '/var/usrliblocale' '/var/opt' '/var/srv' '/var/nm-system-connections' '/var/lib/AccountsService' '/var/lib/bluetooth' '/var/lib/NetworkManager' '/etc/localtime' '/etc/locale.gen' '/etc/locale.conf')

# Load script extensions from /arkdep/extensions
load_extensions=0

# Remove tarball from cache once deployment is finished
remove_tar_after_deployment=1

# Update diff styling, available styles: 'list'
update_diff_style='list'

# Before making changes to the system show diff and ask for confirmation
interactive_mode=1
END
