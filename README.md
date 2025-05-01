# os-installer-config-arkdep
Configuration files for [os-installer](https://gitlab.gnome.org/p3732/os-installer), Arkane Linux arkdep.

> [!NOTE]
> Installing to a partition is not functional on os-installer 0.3, the EFI detection bug *almost* fixed on master and should be fixed in future releases

## Scripts configuration overview
### prepare.sh
- Ensure user is in sudo or wheel group

### install.sh
- Run install.sh.d/* with OS-Installer (OSI) environment variables

### configure.sh
- Run configure.sh.d/* with OS-Installer (OSI) environment variables

## install.sh.d
#### 01-checks.sh
- Ensure all install environment variables exist

#### 02-partitioning.sh
- Creating, formatting and mounting partitions

#### 03-systemd-boot.sh
- Copying systemd-boot EFI binaries and loader.conf

#### 04-initialize-arkdep.sh
- Initializing arkdep

## configure.sh.d
#### 01-checks.sh
- Ensure all install environment variables exist

#### 02-overlay.sh
- Copying overlay_arkdep to /arkdep/overlay

#### 03-arkdep-gnupg.sh
- Copying bits/trusted-keys to /arkdep/keys/trusted-keys

#### 04-localization.sh
- Configuring vconsole.conf
- Needed for correct keyboard layout while encrypting

#### 05-systemd-boot.sh
- Setting correct systemd-boot template

#### 06-arkdep.sh
- Deploying arkdep image
- Creating swap file

#### 07-dconf.sh
- Compiling and copying dconf db

#### 08-cleanup.sh
- Umounting and deleting temp /boot folder


<!---
```
bits
├── part.sfdisk
|   └── * Used in 02-partitioning.sh for format drive
└── trusted-keys
    └── * Used in 03-arkdep-gnupg.sh for copy to /arkdep/keys/

overlay_arkdep
└── etc
    ├── dracut.conf.d
    │   └── arkane.conf
    |       ├── * dracut config
    |       └── * Also exist in image
    ├── fstab
    |   ├── * Correct fstab 
    |   └── * Using arkane_root and arkane_esp labels for identify root and boot partitions
    ├── group
    |   ├── * Have root and wheel groups
    |   ├── * Used for be able to add user to wheel group
    |   └── * Other groups exist in /usr/lib/group
    └── hostname
        └── * Hostname after installing
scripts
├── configure.sh
    * Used for run configure.sh.d/* with OS-Installer (OSI) environment variables
├── configure.sh.d
│   ├── 01-checks.sh
|   |   └── * Ensure all needed configure environment variables exist
│   ├── 02-overlay.sh
|   |   └── * Copying overlay_arkdep to /arkdep/overlay
│   ├── 03-arkdep-gnupg.sh
|   |   └── * Copying bits/trusted-keys to /arkdep/keys/trusted-keys
│   ├── 04-localization.sh
|   |   ├── * Configuring vconsole.conf 
|   |   └── * Needed for correct keyboard layout while encrypting
│   ├── 05-systemd-boot.sh
|   |   ├── * Setting correct systemd-boot template
|   |   └── * Using arkdep_root label as root partition without encrypting
│   ├── 06-arkdep.sh
|   |   ├── * Deploying arkdep image
|   |   └── * Creating swap file
│   ├── 07-dconf.sh
|   |   └── * Compiling and copying dconf db
│   └── 08-cleanup.sh
|       └── * Umount and deleting temp /boot folder
├── install.sh
|   * Used for run install.sh.d/*
├── install.sh.d
│   ├── 01-checks.sh
|   |   └── * Ensure all install environment variables exist  
│   ├── 02-partitioning.sh
|   |   └── * Formatting and mounting partitions
│   ├── 03-systemd-boot.sh
|   |   └── * Copying systemd-boot EFI binaries and loader.conf
│   └── 04-initialize-arkdep.sh
|       └── * Initializing arkdep
└── prepare.sh
    └── * Ensure user is in sudo or wheel group
```
-->