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
[[ -z ${OSI_DEVICE_IS_PARTITION+x} ]] && quit_on_err 'OSI_DEVICE_OS_PARTITION is not set'
[[ -z ${OSI_DEVICE_EFI_PARTITION+x} ]] && quit_on_err 'OSI_DEVICE_EFI_PARTITION is not set'
[[ -z ${OSI_USE_ENCRYPTION+x} ]] && quit_on_err 'OSI_USE_ENCRYPTION is not set'
[[ -z ${OSI_ENCRYPTION_PIN+x} ]] && quit_on_err 'OSI_ENCRYPT_PIN is not set'
[[ -z ${OSI_USER_NAME+x} ]] && quit_on_err 'OSI_USER_NAME is not set'
[[ -z ${OSI_USER_AUTOLOGIN+x} ]] && quit_on_err 'OSI_USER_AUTOLOGIN is not set'
[[ -z ${OSI_USER_PASSWORD+x} ]] && quit_on_err 'OSI_USER_PASSWORD is not set'
[[ -z ${OSI_FORMATS+x} ]] && quit_on_err 'OSI_FORMATS is not set'
[[ -z ${OSI_TIMEZONE+x} ]] && quit_on_err 'OSI_TIMEZONE is not set'
[[ -z ${OSI_ADDITIONAL_SOFTWARE+x} ]] && quit_on_err 'OSI_ADDITIONAL_SOFTWARE is not set'
[[ -z ${OSI_ADDITIONAL_FEATURES+x} ]] && quit_on_err 'OSI_ADDITIONAL_FEATURES is not set'

