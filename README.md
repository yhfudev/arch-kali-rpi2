arch-kali-rpi2
==============

The build scripts for Kali image of Raspberry Pi 2,
supports both Debian & Arch Linux.


Build
-----

You may compile the kali image for Raspberry Pi 2 in one step:

    git clone https://github.com/yhfudev/arch-kali-rpi2.git
    cd arch-kali-rpi2
    sudo ./runme.sh

You may want to run above commands in a virtual machine by user root,
otherwise you may be annoyed by the sudo command :-)

Install
-------
Install to SD card by:

    dd bs=4M if=src/kali-rpi2-image-1.1.0-armhf.img of=/dev/mmcblk0 && sync


### Speeding up writing image

If you install following tools in your build host before compiling the image, you'll get a compressed image file and bmap config file, and you may speed up writing the image file to a SD card:

    apt-get install bsdtar bmap-tools pixz

To install the image file to your SD card:

    sudo bmaptool copy kali-rpi2-image-1.1.0-armhf.img.xz /dev/mmcblk0

Config
------
You may be also interest in config or install other packages after booting the Kali:
(user "root" login with password "toor")

    # expanded the image to the full size
    apt-get install parted sudo
    /scripts/rpi-wiggle.sh
    
    # Full Kali Linux build
    apt-get update
    apt-get install kali-linux-full
    
    # setup ssh server
    apt-get install openssh-server
    update-rc.d -f ssh remove
    update-rc.d -f ssh defaults
    rm /etc/ssh/ssh_host_*
    dpkg-reconfigure openssh-server
    service ssh restart

Features
--------

* Supports the latest Raspberry Pi 2
* Fix X window frozen problem caused by kernel module mismatch
* automatically download and install prerequisites
* automatically download, setup, and cache source/tool trees
* Supports dpkg cache, so you won't wait after the first run of this software
* Supports multiple linux distributions, such Debian, Arch (or Redhat, not test yet)

That's all. Have fun!
