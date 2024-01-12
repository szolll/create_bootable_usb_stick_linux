#!/bin/bash
# Bootable USB Creator Script
#
# Author: Daniel Sol / https://github.com/szolll/
#
# Version: 1.0
#
# Description:
#   This script automates the process of creating a bootable Linux USB stick.
#   It installs necessary packages, downloads the desired Linux distribution,
#   customizes the OS, and writes the image to a selected USB stick.
#
# Usage:
#   1. Save this script as 'create_bootable_usb.sh'.
#   2. Make the script executable: chmod +x create_bootable_usb.sh
#   3. Run the script as root or with sudo: sudo ./create_bootable_usb.sh
#   4. Follow the on-screen instructions.
#
#   Note: Ensure that you have internet access and the required permissions 
#         to run the script. This script assumes a Debian-based system.
#
#   Warning: This script will format the selected USB stick and all data on it 
#            will be erased. Make sure to back up any important data before proceeding.
#
# MIT License
# Copyright (c) [2023] [Daniel Sol]
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


# Function to cleanup on exit
cleanup() {
    echo "Cleaning up..."
    rm -f /tmp/img.dd
    # Add other cleanup tasks here
}

# Trap errors and script interruption
trap cleanup EXIT
trap 'echo "Script interrupted."; exit 1' SIGINT

# Check for root privileges
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root. Please run with sudo."
    exit 1
fi

# Update and install necessary packages
sudo apt-get update
sudo apt-get install live-build debootstick -y

# Switch to root
sudo su -

# Download the OS
debootstrap --variant=minbase focal /tmp/focal_tree

# Customize the OS
chroot /tmp/focal_tree
apt update -y
apt upgrade
apt install apt-transport-https software-properties-common net-tools ...
# Other customizations follow...
exit

# Generate the bootable image
debootstick --config-root-password-ask /tmp/focal_tree /tmp/img.dd

# Detect and list USB sticks
echo "Detecting available USB sticks..."
readarray -t usb_devices <<< "$(lsblk -d -n -p -o NAME,SIZE,MODEL | grep 'sd')"

if [ ${#usb_devices[@]} -eq 0 ]; then
    echo "No USB sticks detected. Please insert a USB stick and retry."
    exit 1
fi

echo "Available USB sticks:"
for i in "${!usb_devices[@]}"; do
    echo "$((i+1))) ${usb_devices[$i]}"
done

# User selects a USB stick
while true; do
    read -p "Enter the number of the USB stick you want to use: " selection
    if [[ $selection =~ ^[0-9]+$ ]] && [ $selection -ge 1 ] && [ $selection -le ${#usb_devices[@]} ]; then
        usb_device=$(echo "${usb_devices[$((selection-1))]}" | awk '{print $1}')
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

# Confirm selection
echo "You have selected: $usb_device"
read -p "Are you sure you want to write to $usb_device? This will erase all data. (y/N): " confirmation
if [[ $confirmation != "y" && $confirmation != "Y" ]]; then
    echo "Operation cancelled."
    exit 1
fi

# Ensure the selected device is not mounted
if mount | grep -q "$usb_device"; then
    echo "Error: $usb_device is mounted. Please unmount it before continuing."
    exit 1
fi

# Optional: Check the size of the USB stick
usb_size=$(lsblk -dn -o SIZE -b "$usb_device" | awk '{print $1}')
img_size=$(stat -c%s /tmp/img.dd)
if [ "$img_size" -gt "$usb_size" ]; then
    echo "Error: Insufficient space on $usb_device. Image size is larger than the USB stick capacity."
    exit 1
fi

# Write the image to the USB stick
echo "Writing image to $usb_device. Please wait..."
if sudo dd bs=10M if=/tmp/img.dd of=$usb_device status=progress; then
    sync
    echo "Bootable USB stick created successfully."
else
    echo "Failed to create bootable USB stick."
    exit 1
fi

# Optional: Verify the written data
echo "Verifying written data..."
if sudo dd if=$usb_device bs=10M count=$(($img_size / 1024 / 1024)) | md5sum -c <(md5sum /tmp/img.dd); then
    echo "Verification successful."
else
    echo "Verification failed. The USB stick might not be bootable."
fi

echo "Script completed. You can now use the USB stick to boot into your custom Linux environment."

# Offer to create another bootable USB or exit
while true; do
    read -p "Do you want to create another bootable USB stick? (y/N): " choice
    case $choice in
        [Yy]* ) exec $0;; # Restart the script
        * ) echo "Exiting."; break;;
    esac
done
