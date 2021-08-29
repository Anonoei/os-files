#!/bin/bash
###########################################################################
#                                                                         #
#         MMMM     MMMM      MMMM    M   M          MMM    M   M          #
#        M    M    M   M    M        M   M         M       M   M          #
#        MMMMMM    MMMM     M        MMMMM          MM     MMMMM          #
#        M    M    M   M    M        M   M            M    M   M          #
#        M    M    M   M     MMMM    M   M    X    MMM     M   M          #
#                                                                         #
###########################################################################
#--------------------------------  Ver 0.1.1  ----------------------------#
###########################################################################
# Author: Anonoei (https://github.com/anonoei)
# License: GPLv3
##########################
#
##   arch.sh    Arch Linux Installation script    !!! ***NOT WORKING DO NOT USE*** !!!
#
#    NOTE: I am not resposible for any damage this script may cause
#        please be careful and understand the script before running
#
#    This file serves as an installation script for Arch Linux
#    This file will partition the user-selected drive with BTRFS (not ext4)
#    The option for LUKS encryption will be offered, and maybe for BIOS/UEFI

### ----------------------------- ###
#     Pick Installation Drive
### ----------------------------- ###
echo "Pick installation drive..."

DriveValid='0'
DriveName='none'
while [ $DriveValid -eq '0' ]
do
  clear
  sudo fdisk -l
  echo "=================================================="
  echo "Specify the drive you'd like to install Arch to:"
  echo "example: sda or nvme0n1, etc"
  read DriveName
  DriveName=/dev/$DriveName
  if [[ -e "$DriveName" ]]
  then
    echo -ne "Are you sure you'd like to use $DriveName?[yN] "
    read answer
      if [[ "${answer}" =~ ^[Yy]$ ]]
      then
        DriveValid='1'
      fi
  else
    echo "That drive name wasn't valid! $DriveName"
    read -t 5 -p "press any key to continue"
  fi
done

echo "finished!"

### ----------------------------- ###
#   Set Drive Name Partition format
### ----------------------------- ###
echo "Setting partition formatting and size..."

DriveNameP='none'
if [[$DriveName -eq '/dev/sda']]; then
  DriveNameP=$DriveName
elif [[ $DriveName -eq '/dev/nvme0n1' ]]; then
  DriveNameP=$DriveNamep
fi

echo "Using drive $DriveName for installation"
DriveInstallMethod='1'
DriveBootSize='1GiB'
DriveSwapSize='8GiB'
DriveRootSize='max'
UsingSwap='1'
# echo "Would you like to install with BIOS or UEFI?"
## Boot Partition Size ##
echo "How big would you like your EFI partition?"
echo "valid: 512MiB - default size 1GiB"
# parted $DriveName mklabel gpt mkpart P1 efi 1MiB $DriveBootSize
BootPartName=$DriveNameP1
## Use a swapfile ##
echo "Would you like to use a swapfile? [Yn] "
# if yes, UsingSwap = 1 / else UsingSwap = 0
if [ $UsingSwap -eq '1' ]
then
  echo "NOTE: When hibernating ALL memory will be swapped, size accordingly."
  echo "valid: 2GiB - default: 8GiB"
  # parted $DriveName mkpart P2 swap $DriveBootSize $DriveSwapSize
  SwapPartName=$DriveNameP2
fi
#
## Root filesystem size ##
echo "How big would you like your root filesystem?"
echo "valid: 128GiB - default: max"
if [ $UsingSwap -eq '1' ]
then
  # parted $DriveName mkpart P3 btrfs $DriveSwapSize $DriveRootSize
  RootPartName=$DriveNameP2
else
  # parted $DriveName mkpart P2 btrfs $DriveSwapSize $DriveRootSize
  RootPartName=$DriveNameP3
fi

echo "finished!"

### ----------------------------- ###
#     Create LUKS partition
### ----------------------------- ###
echo "Creating LUKS partition..."
echo "Name is /dev/mapper/luks"

echo "TYPE: 'YES' for luks partition"
echo "Then enter your decryption password (twice)"
cryptsetup luksFormat $RootPartName

cryptsetup open $RootPartName luks

echo "finished!"

### ----------------------------- ###
#     Format Partitions
### ----------------------------- ###
echo "Formatting partitions..."

# Format boot partition
mkfs.vfat -F32 $DriveNameP1

if [[ $UsingSwap - eq '1' ]]; then
  # Format swap partition
fi
# Format root filesystem
mkfs.btrfs /dev/mapper/luks

echo "finished!"

### ----------------------------- ###
#     Mount Partitions
### ----------------------------- ###
echo "Mounting partitions..."

mount /dev/mapper/luks /mount
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@var
umount /mnt
mount -o subvol=@,ssd,compress=lzo,noatime,nodiratime /dev/mapper/luks /mnt
mkdir /mnt/{boot,home,var}
mount -o subvol=@home,ssd,compress=lzo,noatime,nodiratime /dev/mapper/luks /mnt/home
mount -o subvol=@var,ssd,compress=lzo,noatime,nodiratime /dev/mapper/luks /mnt/var
mount $DriveName /mnt/boot

echo "finished!"


### ----------------------------- ###
#     Install base Arch
### ----------------------------- ###
echo "Install and setup base Arch Linux..."
echo "Do you have an 'intel' or 'amd' CPU?"
read CPUarch
archvalid='0'
while [ $archvalid -eq '0' ]
do
  if [[ $CPUarch -eq 'amd' ]]; then
    archvalid='1'
    pacstrap /mnt base base-devel linux linux-firmware linux-headers linux-lts linux-lts-headers btrfs-progs nano vi sudo zsh zsh-autosuggestions zsh-syntax-highlighting amd-ucode iwd iw dhcpcd
  elif [[ $CPUarch -eq 'intel' ]]; then
    archvalid='1'
    pacstrap /mnt base base-devel linux linux-firmware linux-headers linux-lts linux-lts-headers btrfs-progs nano vi sudo zsh zsh-autosuggestions zsh-syntax-highlighting intel-ucode iwd iw dhcpcd
  else
    echo "Invalid CPU arcitecture..."
    read -t 5 -p "press any key to continue"
  fi
done
genfstab -U /mnt >> /mnt/etc/fstab

echo "chrooting into installed system..."

arch-chroot /mnt
echo "Enter your wanted hostname: "
read hostname
echo "# Generated by arch.sh" > /etc/hostname
echo $hostname >> /etc/hostname
# ln -sf /usr/share/zoneinfo/US/Pacific /etc/localtime
hwclock --systohc
echo "====================================="
echo "Uncomment en_US.UTF-8"
nano /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
echo "====================================="
echo "Set the root password"
passwd

## Setup /etc/hosts
echo "# Generated by arch.sh" > /etc/hosts
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1   localhost" >> /etc/hosts
echo "127.0.1.1 $hostname.local $hostname" >> /etc/hosts

## Setup /etc/mkinitcpio.conf
echo "====================================="
echo "Add 'encrypt' and 'btrfs' inside of 'HOOKS='"
nano /etc/mkinitcpio.conf
echo "Generating mkinitcpio"
mkinitcpio -p linux

## Install systemd-boot
bootctl --path=/boot install

## Add Arch to boot manager
echo "Take a picture of the UUID and write it in the location provided..."
blkid /dev/mapper/luks
echo "# Generated by arch.sh" > /boot/loader/entries/arch.conf
echo "title Arch Linux" >> /boot/loader/entries/arch.conf
echo "linux /vmlinuz-linux" >> /boot/loader/entries/arch.conf
if [[ $CPUarch -eq 'amd' ]]; then
  echo "initrd /amd-ucode.img" >> /boot/loader/entries/arch.conf
elif [[ $CPUarch -eq 'intel' ]]; then
  echo "initrd /intel-ucode.img" >> /boot/loader/entries/arch.conf
fi
echo "initrd /initramfs-linux.img" >> /boot/loader/entries/arch.conf
echo "options cryptdevice=UUID=XXput-it-hereXX:luks:allow-discards root=/dev/mapper/luks rootflags=subvol@ rd.luks.options=discard rw" >> /boot/loader/entries/arch.conf

## Add Arch as default to loader
echo "default arch.conf" >> /boot/loader/loader.conf

echo "======================================"
echo "System finished installing..."
echo "Would you like to download the next script to your new system?"
read answer
if [[ "${answer}" =~ ^[Yy]$ ]]; then
  cd /root
  git clone https://github.com/devonadams/os-files/linux/installation/desktop.sh
fi
echo "Rebooting!"
exit
umount -R /mnt
echo "finished!"
reboot
