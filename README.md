# create_bootable_usb_stick_linux


Quick and dirty how to create a bootable linux usb stick with your favo tools

1 

sudo su -

2
Download the os with debootstrap, check debootstrap for other OS's you can install

debootstrap --variant=minbase focal /tmp/focal_tree

3
Customize it your OS
       
chroot /tmp/focal_tree; [...]; exit
       
3.A Prep apt 
apt update -y ; apt upgrade 
              
              
3.B Add universe repo
sudo add-apt-repository universe ; 
              
3.C Install Software
apt install net-tools terminator vim xfce4 xfce4-terminal 
              
3.D If asked select lightdm

3.F  Add vscodium
wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg

3.G Add the vscodium repository
echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main' | sudo tee /etc/apt/sources.list.d/vscodium.list


        
4 Generate the bootable image:
       
 debootstick --config-root-password-ask /tmp/jessie_tree /tmp/img.dd

 4.A Enter root password for your new live stick
 
              Enter root password:
              Enter root password again:

5.
Now inset a usb stick, and find the device name with

lsblk

6
Now write the dd image to the stick

sudo dd bs=10M if=Documents/live_ubu_focal_rescue.dd of=/dev/sdb

You should end up with something like this. 

554+1 records in
554+1 records out
5812256768 bytes (5,8 GB, 5,4 GiB) copied, 175,691 s, 33,1 MB/s

We'll test the stuff later...

Looks somewhat like this.. 
       cp /tmp/img.dd /tmp/img.dd-test    # let's work on a copy, our test is destructive
       truncate -s 2G /tmp/img.dd-test    # simulate a copy on a 2G-large USB stick
       kvm -m 2048 -hda /tmp/img.dd-test  # the test itself (BIOS mode)

       5- Copy the boot image to a USB stick or disk.
       dd bs=10M if=/tmp/img.dd of=/dev/your-device

       The USB device may now be booted on any BIOS or UEFI system.
