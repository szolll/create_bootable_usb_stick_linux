
# Create a Bootable Live USB Stick Running Ubuntu or Any Other Linux Flavor

You can run the bash script "create_bootable_usb.sh" or follow the steps provided below.

This is a quick and dirty guide to creating a bootable Linux USB stick with your favorite tools.

On your host system, first update your package list and install `live-build`:

```
sudo apt-get update && sudo apt-get install live-build -y
```

### Steps

1. **Switch to Root User**

    ```bash
    sudo su -
    ```

2. **Download the OS Using debootstrap**

    Download the base system. You can check debootstrap for other OS versions you can install:

    ```bash
    debootstrap --variant=minbase focal /tmp/focal_tree
    ```

3. **Customize Your OS Using chroot**

    Make changes to your new OS. Note that changes made after this point are stored only in the new live version.

    ```
    chroot /tmp/focal_tree
    ```

3.A **Prepare apt**

    Update the package list and install necessary tools:

    ```
    apt update -y && apt upgrade -y && apt install apt-transport-https
    ```

3.B **Add Universe Repository**

    Add the universe repository and update the package list:

    ```
    add-apt-repository universe
    add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) main universe restricted multiverse"
    apt-get update
    ```

3.C **Install Common Software**

    Install common tools and applications:

    ```
    apt install software-properties-common net-tools terminator filezilla vim xfce4 xfce4-terminal xfce4-goodies xubuntu-desktop openssh-server tldr tigervnc-viewer sudo wireless-tools laptop-detect locales curl clamav-daemon nano less gparted gedit
    ```

3.C.1 **For Server Recovery**

    ```
    apt install ipmitool
    ```

3.C.2 **Improve Battery Life for Laptops**

    ```
    apt install tlp tlp-rdw
    tlp start
    systemctl enable tlp.service
    ```

3.D **Optionally Install apt-fast**

    ```
    add-apt-repository ppa:apt-fast/stable
    apt-get update
    apt-get install apt-fast
    ```

    If asked, select lightdm.

4. **Add VSCodium for Development**

    Download and add the VSCodium key:

    ```
    wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
    ```

4.A **Add the VSCodium Repository**

    ```
    echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main' | tee /etc/apt/sources.list.d/vscodium.list
    ```

5. **Add Chrome Browser**

5.A **Add Key**

    ```
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
    ```

5.B **Add Repository**

    ```
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
    ```

5.C **Update apt**

    ```
    apt-get update
    ```

5.D **Install Chrome**

    ```
    apt-get install google-chrome-stable
    ```

6. **Purge Unwanted Software**

    ```
    apt-get purge -y transmission-gtk transmission-common gnome-mahjongg gnome-mines gnome-sudoku aisleriot hitori
    ```

7. **Generate Locales**

    Select `en_US.ISO-8859-1` and `en_US.UTF-8 UTF-8`, and then `C.UTF-8` as the default:

    ```
    dpkg-reconfigure locales
    ```

8. **Add a User with a Home Directory**

    ```
    useradd -m <your_username_here>
    ```

9. **Clean up apt**

    ```
    apt-get autoremove -y && apt-get clean
    ```

10. **Set Hostname**

    ```
    echo "ubuntu-fs-live" > /etc/hostname
    ```

11. **Configure Machine-ID and Divert**

    ```
    dbus-uuidgen > /etc/machine-id
    ln -fs /etc/machine-id /var/lib/dbus/machine-id
    ```

12. **Remove Machine-ID**

    ```
    truncate -s 0 /etc/machine-id
    ```

13. **Clean up bash_history**

    ```
    rm -rf /tmp/* ~/.bash_history
    export HISTSIZE=0
    ```

14. **Exit from chroot**

    ```
    exit
    ```

15. **Generate the Bootable Image**

    ```
    debootstick --config-root-password-ask /tmp/focal_tree /tmp/img.dd
    ```

15.A **Enter Root Password for Your New Live Stick**

    Follow the prompts to enter and confirm the root password.

16. **Insert a USB Stick and Find the Device Name**

    ```
    lsblk
    ```

17. **Write the Image to the USB Stick**

    Replace `/dev/sdb` with your USB device name:

    ```
    sudo dd bs=10M if=/tmp/img.dd of=/dev/sdb
    ```

    You should see an output similar to:

    ```
    554+1 records in
    554+1 records out
    5812256768 bytes (5.8 GB, 5.4 GiB) copied, 175.691 s, 33.1 MB/s
    ```

18. **Test the Image**

    Create a test copy and simulate the USB stick on a virtual machine:

    ```
    cp /tmp/img.dd /tmp/img.dd-test    # Work on a copy, the test is destructive
    truncate -s 2G /tmp/img.dd-test    # Simulate a 2G-large USB stick
    kvm -m 2048 -hda /tmp/img.dd-test  # Test in BIOS mode
    ```

19. **Copy the Boot Image to a USB Stick or Disk**

    ```
    dd bs=10M if=/tmp/img.dd of=/dev/your-device
    ```

    The USB device is now ready to be booted on any BIOS or UEFI hardware.

---

### Links
- [Debootstrap Documentation](https://manpages.ubuntu.com/manpages/jammy/en/man8/debootstrap.8.html)
- [Live-Build Documentation](https://howtoinstall.co/package/live-build)
- [Debootstick Documentation](https://manpages.ubuntu.com/manpages/focal/en/man8/debootstick.8.html)
