# create_bootable_usb_stick_linux


Quick and dirty how to create a bootable linux usb stick with your favo tools

On your host system

           sudo apt-get update ; sudo apt-get install live-build -y


1 Switch to root

              sudo su -

2
Download the os with debootstrap, check debootstrap for other OS's you can install

              debootstrap --variant=minbase focal /tmp/focal_tree

3
Customize your OS with help of chroot (* Changes made after this point are stored only in the new live version)
                     
              chroot /tmp/focal_tree; [...]; exit
                     
3.A 
Prep apt 
              
              apt update -y ; apt upgrade ; apt install apt-transport-https            
                          
3.B
Add universe repo

              add-apt-repository universe ; add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) main universe restricted multiverse" ;  apt-get update
                          
3.C Install more commen Software

              apt install net-tools terminator vim xfce4 xfce4-terminal xfce4-goodies xubuntu-desktop openssh-server tigervnc-viewer sudo wireless-tools laptop-detect locales curl clamav-daemon nano less gparted gedit

3.C.1
For server recovery 
                            
              apt install ipmitool

3.C.2
Improve Battery for laptops
                            
               apt install tlp tlp-rdw ; tlp start ; systemctl enable tlp.service


                            Optionally install
                            add-apt-repository ppa:apt-fast/stable ; apt-get update ; apt-get install apt-fast  
              

                            
3.D
If asked select lightdm
              
              4
Add vscodium for dev
              
              wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
              
              4.A
Add the vscodium repository
              
              echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main' | sudo tee /etc/apt/sources.list.d/vscodium.list
              
              5 
Add Chrome Browser
              
              5.A

Add key
              wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
              
              5.B
Add Repo
              echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
              
              5.C
Now update apt
              apt-get update
              
              5.F
And install Chrome
              apt-get install google-chrome-stable
              
              
              
              6
Purge Unwanted software
              apt-get purge -y transmission-gtk transmission-common gnome-mahjongg gnome-mines gnome-sudoku aisleriot hitori
              
              
              xx
              Generate locales  (* select en_us_ISO-8859-1 and en_US.UTF-8 UTF-8 & then C.UTF-8 for default)
              dpkg-reconfigure locales 

              xx
              Add our favo user with a home dir
              useradd -m username <your_user_here>
              
              xx
              Clean up apt 
              
              apt-get autoremove -y ; apt-get clean
              
              xx
              Set hostname
              
              echo "ubuntu-fs-live" > /etc/hostname
              
              xx
              Configure machine-id and divert
              
              dbus-uuidgen > /etc/machine-id ; ln -fs /etc/machine-id /var/lib/dbus/machine-id
              
              xx remove machine-id
              truncate -s 0 /etc/machine-id
              
              xx 
              rm -rf /tmp/* ~/.bash_history
              export HISTSIZE=0

              xx
              Now Exit from the chroot
              exit
                      

xx
Generate the bootable image:
       
 debootstick --config-root-password-ask /tmp/jessie_tree /tmp/img.dd

 5.A Enter root password for your new live stick
 
              Enter root password:
              Enter root password again:

5




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


Links
https://manpages.ubuntu.com/manpages/jammy/en/man8/debootstrap.8.html
https://howtoinstall.co/package/live-build
https://manpages.ubuntu.com/manpages/focal/en/man8/debootstick.8.html
