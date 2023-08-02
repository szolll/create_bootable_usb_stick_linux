# create_bootable_usb_stick_linux
Quick and dirty how to create a bootable linux usb stick with your favo tools


       debootstrap --variant=minbase jessie /tmp/jessie_tree

       2- (Optionally) customize it:
       chroot /tmp/jessie_tree; [...]; exit

       3- Generate the bootable image:
       debootstick --config-root-password-ask /tmp/jessie_tree /tmp/img.dd
       Enter root password:
       Enter root password again:
       OK
       [...]

       4- Test it with kvm.
       cp /tmp/img.dd /tmp/img.dd-test    # let's work on a copy, our test is destructive
       truncate -s 2G /tmp/img.dd-test    # simulate a copy on a 2G-large USB stick
       kvm -m 2048 -hda /tmp/img.dd-test  # the test itself (BIOS mode)

       5- Copy the boot image to a USB stick or disk.
       dd bs=10M if=/tmp/img.dd of=/dev/your-device

       The USB device may now be booted on any BIOS or UEFI system.
