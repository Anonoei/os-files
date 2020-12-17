#!/bin/bash
###############################################################################################
#                                                                                             #
#        MMMM     MMMMMM     MMM    M  M    MMMMM     MMM     MMMM           MMM    M  M      #
#        M   M    M         M       M  M      M      M   M    M   M         M       M  M      #
#        M   M    MMM        MM     MMMM      M      M   M    MMMM           MM     MMMM      #
#        M   M    M            M    M  M      M      M   M    M                M    M  M      #
#        MMMM     MMMMMM    MMM     M  M      M       MMM     M        X    MMM     M  M      #
#                                                                                             #
###############################################################################################
#----------------------------------------  Ver 0.0.1  ----------------------------------------#
###############################################################################################
# Author: Devon Adams (https://github.com/devonadams)
# License: GPLv3
##########################
#
##   desktop.sh Linux Desktop Environment install script        !!! ***NOT WORKING DO NOT USE*** !!!
#
#    NOTE: I am not resposible for any damage this script may cause
#        please be careful and understand the script before running
#
#    This file serves as an installation file for a Linux Desktop Environment
#

echo "Before running, please ensure you're connected to the internet"
read -t 5 -p "press any key to continue"

### ----------------------------- ###
#     Choose distribution
### ----------------------------- ###
DistValid='0'
while [ $DistValid -eq '0' ]
do
  clear
  echo "============================================="
  echo "What distribution are you using?"
  echo "arch, debian, rhel > "
  read install
  if [[ $install -eq 'arch' ]]; then
    install='pacman -S '
    DistValid='1'
  elif [[ $install -eq 'debian' ]]; then
    install='apt install '
    DistValid='1'
  elif [[ $isntall -eq 'rhel' ]]; then
    install='dnf install '
    DistValid='1'
  else
    echo "Invalid distribution!"
    read -t 5 -p "press any key to continue"
  fi
done

### ----------------------------- ###
#     Choose Desktop Environment
### ----------------------------- ###
DesktopValid='0'
packages='none'
while [ $DesktopValid -eq '0' ]
do
  clear
  echo "What desktop environment would you like to use?"
  echo "gnome, kde, mate, xfce > "
  read DesktopEnvironment
  if [[ $DesktopEnvironment -eq 'gnome' ]]; then
    DesktopPackages='gnome'
    DesktopValid='1'
  elif [[ $DesktopEnvironment -eq 'kde' ]]; then
    DesktopPackages='lightdm lightdm-gtk-greeter accountsservice xorg-server plasma-desktop plasma-wayland-session'
    DesktopValid='1'
  elif [[ $DesktopEnvironment -eq 'mate' ]]; then
    DesktopPackages='mate'
    DesktopValid='1'
  elif [[ $DesktopEnvironment -eq 'xfce' ]]; then
    DesktopPackages='xfce'
    DesktopValid='1'
  else
    echo "Invalid desktop environment!"
    read -t 5 -p "press any key to continue"
  fi
done

### ----------------------------- ###
#     Install Destop Environment
### ----------------------------- ###
packages=$DesktopPackages
#
## Personal Preferance packages ##
PersonalPackages='terminator atom chromium firefox nautilus dosfstools mtools'
echo "Would you like to install additional personal packages?"
echo "$PersonalPackages > "
read answer
if [[ "${answer}" =~ ^[Yy]$ ]]; then
  packages+=$PersonalPackages
fi
#
## Security / Authentication packages ##
SecurityPackages='keepassxc yubioauth-desktop yubikey-manager-qt yubikey-personalization-gui'
echo "Would you like to install additional security packages?"
echo "$SecurityPackages > "
read answer
if [[ "${answer}" =~ ^[Yy]$ ]]; then
  packages+=$SecurityPackages
fi
#
## Nvidia Packages (the devil) ##
NvidiaPackages='nvidia nvidia-utils nvidia-settings'
echo "Would you like to install additional nvidia packages?"
echo "$NvidiaPackages > "
read answer
if [[ "${answer}" =~ ^[Yy]$ ]]; then
  packages+=$NvidiaPackages
fi
#
## Programming Packages ##
ProgrammingPackages='gcc gdb geany'
echo "Would you like to install additional nvidia packages?"
echo "$ProgrammingPackages > "
read answer
if [[ "${answer}" =~ ^[Yy]$ ]]; then
  packages+=$ProgrammingPackages
fi
#
## Some useful packages ##
UsefulPackages='ttf-dejavu pulseaudio pavucontrol'
echo "Would you like to install additional nvidia packages?"
echo "$NvidiaPackages > "
read answer
if [[ "${answer}" =~ ^[Yy]$ ]]; then
  packages+=$NvidiaPackages
fi
#
## i3 Window Manager
i3Packages='i3-gaps i3-status rofi'
echo "Would you like to also install i3 Window Manager?"
read answer
if [[ "${answer}" =~ ^[Yy]$ ]]; then
  packages+=$i3Packages
fi
echo "Packages to install: $packages"

sudo $install $packages

### ----------------------------- ###
#     Enable Desktop
### ----------------------------- ###

if [[ $DesktopEnvironment -eq 'gnome' ]]; then
  sudo systemctl enable gdm
elif [[ $DesktopEnvironment -eq 'kde' ]]; then
  sudo systemctl enable lightdm
elif [[ $DesktopEnvironment -eq 'mate' ]]; then

elif [[ $DesktopEnvironment -eq 'xfce' ]]; then

fi
