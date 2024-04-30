# Ensure user is in sudo group
for group in $(groups); do
	if [[ $group == 'wheel' || $group == 'sudo' ]]; then
		declare -ri sudo_ok=1
	fi
done

# If user is not in sudo group notify and exit with error
if [[ ! -n $sudo_ok ]]; then
	quit_on_err 'The current user is not a member of either the sudo or wheel group, this os-installer configuration requires sudo permissions'
fi

# Ensure all expected osi variables are set
[[ -z ${OSI_LOCALE+x} ]] && quit_on_err 'OSI_LOCALE not set'
[[ -z ${OSI_DEVICE_PATH+x} ]] && quit_on_err 'OSI_DEVICE_PATH not set'
[[ -z ${OSI_DEVICE_IS_PARTITION+x} ]] && quit_on_err 'OSI_DEVICE_IS_PARTITION not set'
[[ -z ${OSI_DEVICE_EFI_PARTITION+x} ]] && quit_on_err 'OSI_DEVICE_EFI_PARTITION not set'
[[ -z ${OSI_USE_ENCRYPTION+x} ]] && quit_on_err 'OSI_USE_ENCRYPTION not set'
[[ -z ${OSI_ENCRYPTION_PIN+x} ]] && quit_on_err 'OSI_ENCRYPTION_PIN not set'

# Check if something is already mounted to $workdir
mountpoint -q $workdir &&
	quit_on_err "$workdir is already a mountpoint, unmount this directory and try again"
