# Maintainer: Yunhui Fu <yhfudev at gmail dot com>

pkgname=kali-rpi2-image
pkgver=1.1.0
pkgrel=1
pkgdesc="Raspberry Pi 2 Kali image"
arch=('i686' 'x86_64' 'arm')
url="https://github.com/yhfudev/arch-kali-rpi2.git"
license=('GPL')

optdepends=(
    'pixz'
    'bmap-tools'
    )

makedepends=(
    'git' 'bc' 'gcc-libs' 'bash'
    'ncurses' 'lzop' 'uboot-tools' # for kernel
    'qemu' 'qemu-user-static-exp' 'binfmt-support' # cross compile and chroot
    'debootstrap' # to create debian rootfs
    'parted' 'dosfstools'
    'yaourt' 'multipath-tools' # for kpartx, in AUR, you need to use yaourt to install it
    #'lib32-libstdc++5' 'lib32-zlib' # for 32 bit compiler
    'base-devel' 'abs' 'fakeroot'
    # 'kernel-package' # debian packages, include make-kpkg
    )
#install="$pkgname.install"
#PKGEXT=.pkg.tar.xz

provides=('kali-rpi2-git')
conflicts=('kali-rpi2')

if [ 0 = 1 ]; then
# config for Raspberry Pi 1
ARCHITECTURE="armel"
#PATCH_MAC80211="kali-arm-build-scripts-git/patches/kali-wifi-injection-3.12.patch"
PATCH_MAC80211="kali-wifi-injection-3.18.patch"
CONFIG_KERNEL="kali-arm-build-scripts-git/kernel-configs/rpi-3.12.config"
PATCH_CONFIG_KERNEL="kali-arm-build-scripts-git/patches/rpi-kernel-config.patch"
FN_RPI_KERNEL=kernel.img
MAKE_CONFIG=bcmrpi_defconfig
else
# config for Raspberry Pi 2
ARCHITECTURE="armhf"
PATCH_MAC80211="kali-wifi-injection-3.18.patch"
CONFIG_KERNEL="rpi2-3.19.config"
PATCH_CONFIG_KERNEL="rpi-kernel-config-3.19.patch"
FN_RPI_KERNEL=kernel7.img
MAKE_CONFIG=bcm2709_defconfig
fi

# Package installations for various sections.
# This will build a minimal XFCE Kali system with the top 10 tools.
# This is the section to edit if you would like to add more packages.
# See http://www.kali.org/new/kali-linux-metapackages/ for meta packages you can
# use. You can also install packages, using just the package name, but keep in
# mind that not all packages work on ARM! If you specify one of those, the
# script will throw an error, but will still continue on, and create an unusable
# image, keep that in mind.
PACKAGES_ARM="abootimg cgpt fake-hwclock ntpdate vboot-utils vboot-kernel-utils uboot-mkimage"
PACKAGES_BASE="kali-menu kali-defaults initramfs-tools sudo parted e2fsprogs usbutils"
PACKAGES_DESKTOP="xfce4 network-manager network-manager-gnome xserver-xorg-video-fbdev"
PACKAGES_TOOLS="passing-the-hash winexe aircrack-ng hydra john sqlmap wireshark libnfc-bin mfoc nmap ethtool"
PACKAGES_SERVICES="openssh-server apache2"
PACKAGES_EXTRAS="iceweasel wpasupplicant"
#PACKAGES_ADDON="fruitywifi wifite xfce4-goodies"
export PACKAGES="${PACKAGES_ARM} ${PACKAGES_BASE} ${PACKAGES_DESKTOP} ${PACKAGES_TOOLS} ${PACKAGES_SERVICES} ${PACKAGES_EXTRAS} ${PACKAGES_ADDON}"

# the image container size
IMGCONTAINER_SIZE=3000 # Size of image in megabytes

# If you have your own preferred mirrors, set them here.
# You may want to leave security.kali.org alone, but if you trust your local
# mirror, feel free to change this as well.
# After generating the rootfs, we set the sources.list to the default settings.
export INSTALL_MIRROR=http.kali.org
export INSTALL_SECURITY=security.kali.org

# the /boot path for u-boot
MNTPOINT_BOOT_FIRMWARE=/boot/firmware/
# the root fs / label
DISKLABEL_ROOTFS=rootfs
# the /boot fs label
DISKLABEL_BOOTFS=BOOTFS

USE_GIT_REPO=1

GITCOMMIT_LINUX=780e68130fba82a525b89e85f051c91b7a508e52
DNSRC_LINUX=linux-${GITCOMMIT_LINUX}

DNSRC_LINUX=linux-raspberrypi-git

source=(
        "kali-arm-build-scripts-git::git+https://github.com/yhfudev/kali-arm-build-scripts.git"
        "${DNSRC_LINUX}::git+https://github.com/raspberrypi/linux.git" # "https://github.com/raspberrypi/linux/archive/${GITCOMMIT_LINUX}.tar.gz"
        "tools-raspberrypi-git::git+https://github.com/raspberrypi/tools.git"
        "firmware-raspberrypi-git::git+https://github.com/raspberrypi/firmware.git"
        "firmware-linux-git::git+https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git"
        "rpiwiggle-git::git+https://github.com/dweeber/rpiwiggle/"
        "kali-wifi-injection-3.18.patch" #"mac80211.patch::https://raw.github.com/offensive-security/kali-arm-build-scripts/master/patches/kali-wifi-injection-3.12.patch"
        "rpi2-3.19.config"
        "rpi-kernel-config-3.19.patch"
        )

md5sums=(
         'SKIP'
         'SKIP'
         'SKIP'
         'SKIP'
         'SKIP'
         'SKIP'
         '37b89f74e3f9f6c20295da564ece5b8f'
         '95560f6b44bf10f75a7515dae9c79dd5'
         'SKIP'
         )
sha1sums=(
         'SKIP'
         'SKIP'
         'SKIP'
         'SKIP'
         'SKIP'
         'SKIP'
         '48ce0c7886128fb068b70b5692b60a6c5aec0e96'
         'c0c30c8d9c53cb6694d22c0aa92d7c28f1987463'
         'SKIP'
         )

pkgver() {
    cd "${srcdir}/kali-arm-build-scripts-git"
    local ver="$(git show | grep commit | awk '{print $2}'  )"
    #printf "r%s" "${ver//[[:alpha:]]}"
    echo ${ver:0:7}
}

PREFIX_TMP="${srcdir}/tmptmp-${pkgname}"

FORMAT_NAME='arm'
FORMAT_MAGIC='\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00'
FORMAT_MASK='\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'
FORMAT_INTERP='/usr/bin/qemu-arm-static'
FORMAT_REGISTRATION=":$FORMAT_NAME:M::$FORMAT_MAGIC:$FORMAT_MASK:$FORMAT_INTERP:"
BINFMT_MISC="/proc/sys/fs/binfmt_misc"

register_qemuarm() {
    # Check if format is not registered already
    if [ ! -f "$BINFMT_MISC/$FORMAT_NAME" ]; then
        echo "Registering arm binfmt_misc support"
        echo "echo '$FORMAT_REGISTRATION' > /proc/sys/fs/binfmt_misc/register" | sudo sh
    else
        echo "Format $FORMAT_NAME already registered."
    fi
}

unregister_qemuarm() {
    # We were asked to drop the registration
    if [ -f "$BINFMT_MISC/$FORMAT_NAME" ]; then
        echo "echo -1 > '$BINFMT_MISC/$FORMAT_NAME'" | sudo sh
    else
        echo "Format $FORMAT_NAME not registered."
    fi
}

kali_rootfs_debootstrap() {
    PARAM_DN_DEBIAN=$1
    shift
    PARAM_DN_RPI=$1
    shift

    # the apt cache folder
    DN_APT_CACHE="${srcdir}/apt-cache-kali-${MACHINEARCH}"
    mkdir -p "${DN_APT_CACHE}"
    mkdir -p "${DN_ROOTFS_DEBIAN}/var/cache/apt/archives"

    # build kali rootfs
    cd "$srcdir"

    if [ ! -f /usr/share/debootstrap/scripts/kali ]; then
        sudo ln -s /usr/share/debootstrap/scripts/sid /usr/share/debootstrap/scripts/kali
    fi
    if [ ! -f /usr/share/debootstrap/scripts/kali ]; then
        echo "Error: no deebootstrap for kali"
        exit 1
    fi

    if [ "${ISCROSS}" = "1" ]; then
        register_qemuarm
    fi

    sudo mount -o bind "${DN_APT_CACHE}" "${DN_ROOTFS_DEBIAN}/var/cache/apt/archives"

    echo "[DBG] debootstrap state 1"
    if [[ -f "${PREFIX_TMP}-FLG_KALI_ROOTFS_STAGE1" ]]; then
        echo "[DBG] SKIP debootstrap state 1"

    else
        # create the rootfs - not much to modify here, except maybe the hostname.
        echo "[DBG] debootstrap --foreign --arch ${MACHINEARCH} kali '${DN_ROOTFS_DEBIAN}'  http://${INSTALL_MIRROR}/kali"
        sudo debootstrap --foreign --no-check-gpg --include=ca-certificates,ssh,vim,locales,ntpdate,usbmount,initramfs-tools --arch ${MACHINEARCH} kali "${DN_ROOTFS_DEBIAN}" "http://${INSTALL_MIRROR}/kali"
        if [ "$?" = "0" ]; then
            touch "${PREFIX_TMP}-FLG_KALI_ROOTFS_STAGE1"
        else
            echo "Error in debootstarap stage 1"
            exit 1
        fi
    fi

    if [ "${ISCROSS}" = "1" ]; then
        sudo cp `which qemu-arm-static` "${DN_ROOTFS_DEBIAN}/usr/bin/"
    fi

    echo "[DBG] debootstrap state 2"
    if [[ -f "${PREFIX_TMP}-FLG_KALI_ROOTFS_STAGE2" ]]; then
        echo "[DBG] SKIP debootstrap state 2"

    else
        sudo chroot "${DN_ROOTFS_DEBIAN}" /usr/bin/env -i LANG=C /debootstrap/debootstrap --second-stage
        if [ "$?" = "0" ]; then
            touch "${PREFIX_TMP}-FLG_KALI_ROOTFS_STAGE2"
        else
            echo "Error in debootstrap stage 2"
            exit 1
        fi
    fi

    echo "[DBG] debootstrap state 2.5"
    sudo rm "${DN_ROOTFS_DEBIAN}/etc/hostname"
    sudo rm ${DN_ROOTFS_DEBIAN}/etc/ssh/ssh_host_*

    # Create sources.list
    cat << EOF > "${PREFIX_TMP}-aptlst1"
deb http://${INSTALL_MIRROR}/kali kali main contrib non-free
deb http://${INSTALL_SECURITY}/kali-security kali/updates main contrib non-free
EOF
    chmod 644 "${PREFIX_TMP}-aptlst1"
    sudo chown root:root "${PREFIX_TMP}-aptlst1"
    sudo mv "${PREFIX_TMP}-aptlst1" "${DN_ROOTFS_DEBIAN}/etc/apt/sources.list"
    if [ ! "$?" = "0" ]; then
        echo "Error in move apt/sources.list 2.5"
        exit 1
    fi

    # Set hostname

    echo "echo kali > '${DN_ROOTFS_DEBIAN}/etc/hostname'" | sudo sh

    # So X doesn't complain, we add kali to hosts
    cat << EOF > "${PREFIX_TMP}-host"
127.0.0.1       kali    localhost
::1             localhost ip6-localhost ip6-loopback
fe00::0         ip6-localnet
ff00::0         ip6-mcastprefix
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
EOF
    chmod 644 "${PREFIX_TMP}-host"
    sudo chown root:root "${PREFIX_TMP}-host"
    sudo mv "${PREFIX_TMP}-host" "${DN_ROOTFS_DEBIAN}/etc/hosts"
    if [ ! "$?" = "0" ]; then
        echo "Error in move hosts"
        exit 1
    fi

    cat << EOF > "${PREFIX_TMP}-net"
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF
    sudo mv "${PREFIX_TMP}-net" "${DN_ROOTFS_DEBIAN}/etc/network/interfaces"

    cat << EOF > "${PREFIX_TMP}-reso"
nameserver 8.8.8.8
EOF
    chmod 644 "${PREFIX_TMP}-reso"
    sudo chown root:root "${PREFIX_TMP}-reso"
    sudo mv "${PREFIX_TMP}-reso" "${DN_ROOTFS_DEBIAN}/etc/resolv.conf"
    if [ ! "$?" = "0" ]; then
        echo "Error in move resolv.conf"
        exit 1
    fi

    export MALLOC_CHECK_=0 # workaround for LP: #520465
    export LC_ALL=C
    export DEBIAN_FRONTEND=noninteractive

    cat << EOF > "${PREFIX_TMP}-deb"
console-common console-data/keymap/policy select Select keymap from full list
console-common console-data/keymap/full select en-latin1-nodeadkeys
EOF
    chmod 644 "${PREFIX_TMP}-deb"
    sudo chown root:root "${PREFIX_TMP}-deb"
    sudo mv "${PREFIX_TMP}-deb" "${DN_ROOTFS_DEBIAN}/debconf.set"
    if [ ! "$?" = "0" ]; then
        echo "Error in move script debconf.set"
        exit 1
    fi

cat << EOF > "${PREFIX_TMP}-fstab"
LABEL=${DISKLABEL_ROOTFS}   /           auto    defaults,noatime,nodiratime,errors=remount-ro  0       1
LABEL=${DISKLABEL_BOOTFS}   ${MNTPOINT_BOOT_FIRMWARE}  auto    defaults,ro,owner,flush,umask=000        0       2

tmpfs           /tmp        tmpfs   nodev,nosuid,size=10%,mode=1777     0       0
#tmpfs           /var/log    tmpfs   nodev,nosuid,size=20%,mode=1755     0       0
proc            /proc       proc    defaults                            0       0
EOF
    chmod 644 "${PREFIX_TMP}-fstab"
    sudo chown root:root "${PREFIX_TMP}-fstab"
    sudo mv "${PREFIX_TMP}-fstab" "${DN_ROOTFS_DEBIAN}/etc/fstab"
    if [ ! "$?" = "0" ]; then
        echo "Error in move etc/fstab"
        exit 1
    fi
    # Stop the boot-sequence whinging about /tmp being read-only before /tmp is mounted:
    touch "${DN_ROOTFS_DEBIAN}/tmp/.tmpfs"

    echo "[DBG] debootstrap state 3"
    if [[ -f "${PREFIX_TMP}-FLG_KALI_ROOTFS_STAGE3" ]]; then
        echo "[DBG] SKIP debootstrap state 3"

    else
        #sudo mkdir -p "${DN_ROOTFS_DEBIAN}/sys"
        #sudo mkdir -p "${DN_ROOTFS_DEBIAN}/proc"
        #sudo mkdir -p "${DN_ROOTFS_DEBIAN}/dev/"
        #sudo mkdir -p "${DN_ROOTFS_DEBIAN}/dev/pts"
        sudo mount -o bind /sys/ "${DN_ROOTFS_DEBIAN}/sys/"
        sudo mount -t proc proc "${DN_ROOTFS_DEBIAN}/proc"
        if [ ! "$?" = "0" ]; then
            echo "Error in mount proc"
            exit 1
        fi
        sudo mount -o bind /dev/ "${DN_ROOTFS_DEBIAN}/dev/"
        if [ ! "$?" = "0" ]; then
            echo "Error in mount dev"
            exit 1
        fi
        sudo mount -o bind /dev/pts "${DN_ROOTFS_DEBIAN}/dev/pts"
        if [ ! "$?" = "0" ]; then
            echo "Error in mount dev/pts"
            exit 1
        fi

        cat << EOF > "${PREFIX_TMP}-ths"
#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
export DEBIAN_FRONTEND=noninteractive

dpkg-divert --add --local --divert /usr/sbin/invoke-rc.d.chroot --rename /usr/sbin/invoke-rc.d
cp /bin/true /usr/sbin/invoke-rc.d
echo -e "#!/bin/sh\nexit 101" > /usr/sbin/policy-rc.d
chmod +x /usr/sbin/policy-rc.d

apt-get update
apt-get --yes --force-yes install locales-all

debconf-set-selections /debconf.set
rm -f /debconf.set

apt-get update
apt-get --yes --force-yes install git-core binutils ca-certificates initramfs-tools uboot-mkimage
apt-get --yes --force-yes install locales console-common less nano git

sed -i -e "s|^[#\w ]\{1,2\}en_US|en_US|g" /etc/locale.gen
locale-gen en_US en_US.UTF-8 "en_US ISO-8859-1"
update-locale LANG="en_US.UTF-8" LANGUAGE="en_US" LC_ALL="en_US.UTF-8"
#dpkg-reconfigure tzdata
#dpkg-reconfigure locales

echo "root:toor" | chpasswd
#USER1=pi ; useradd -m -s /bin/bash -G adm,sudo,plugdev,audio,video,cdrom,floppy,dip \${USER1} && echo "\${USER1}:\${USER1}" | chpasswd

sed -i -e 's/KERNEL\!=\"eth\*|/KERNEL\!=\"/' /lib/udev/rules.d/75-persistent-net-generator.rules
rm -f /etc/udev/rules.d/70-persistent-net.rules
apt-get --yes --force-yes install $PACKAGES

update-rc.d ssh enable

rm -f /usr/sbin/policy-rc.d
rm -f /usr/sbin/invoke-rc.d
dpkg-divert --remove --rename /usr/sbin/invoke-rc.d

rm -f /third-stage
EOF
        chmod +x "${PREFIX_TMP}-ths"
        sudo mv "${PREFIX_TMP}-ths" "${DN_ROOTFS_DEBIAN}/third-stage"
        if [ ! "$?" = "0" ]; then
            echo "Error in move script third-stage"
            exit 1
        fi

        sudo chroot "${DN_ROOTFS_DEBIAN}" /third-stage
        if [ ! "$?" = "0" ]; then
            echo "Error in third-stage"
            exit 1
        fi

        # unmount the cache folder befor clean up, we may reuse the cache for other builds.
        sudo umount "${DN_ROOTFS_DEBIAN}/var/cache/apt/archives"

        cat << EOF > "${PREFIX_TMP}-aptlst"
deb http://http.kali.org/kali kali main non-free contrib
deb http://security.kali.org/kali-security kali/updates main contrib non-free

deb-src http://http.kali.org/kali kali main non-free contrib
deb-src http://security.kali.org/kali-security kali/updates main contrib non-free
EOF
        chmod 644 "${PREFIX_TMP}-aptlst"
        sudo chown root:root "${PREFIX_TMP}-aptlst"
        sudo mv "${PREFIX_TMP}-aptlst" "${DN_ROOTFS_DEBIAN}/etc/apt/sources.list"
        if [ ! "$?" = "0" ]; then
            echo "Error in move apt/sources.list final: ${DN_ROOTFS_DEBIAN}/etc/apt/sources.list"
            exit 1
        fi

        cat << EOF > "${PREFIX_TMP}-cln"
#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
export DEBIAN_FRONTEND=noninteractive
rm -rf /root/.bash_history
apt-get update
apt-get clean
/etc/init.d/dbus stop
/etc/init.d/ssh  stop
rm -f /debconf.set
rm -f /0
rm -f /hs_err*
rm -f /cleanup
rm -f /usr/bin/qemu*
EOF
        chmod +x "${PREFIX_TMP}-cln"
        sudo mv "${PREFIX_TMP}-cln" "${DN_ROOTFS_DEBIAN}/cleanup"
        if [ ! "$?" = "0" ]; then
            echo "Error in move script cleanup"
            exit 1
        fi

        sudo chroot "${DN_ROOTFS_DEBIAN}" /cleanup
        if [ ! "$?" = "0" ]; then
            echo "Error in chroot cleanup"
            exit 1
        fi
        sudo rm -f "${DN_ROOTFS_DEBIAN}/usr/bin/qemu*"

        sudo umount "${DN_ROOTFS_DEBIAN}/proc/sys/fs/binfmt_misc"
        #if [ ! "$?" = "0" ]; then
            #echo "Error in unmount proc/sys/fs/binfmt_misc"
            #exit 1
        #fi
        sudo umount "${DN_ROOTFS_DEBIAN}/dev/pts"
        if [ ! "$?" = "0" ]; then
            echo "Error in unmount dev/pts"
            exit 1
        fi
        sudo umount "${DN_ROOTFS_DEBIAN}/dev/"
        if [ ! "$?" = "0" ]; then
            echo "Error in unmount dev"
            exit 1
        fi
        sudo umount "${DN_ROOTFS_DEBIAN}/proc"
        if [ ! "$?" = "0" ]; then
            echo "Error in unmount proc"
            exit 1
        fi
        sudo umount "${DN_ROOTFS_DEBIAN}/sys/"

        sudo chown -R root:root "${DN_ROOTFS_DEBIAN}"
        touch "${PREFIX_TMP}-FLG_KALI_ROOTFS_STAGE3"
    fi

    # make sure it umounted
    sudo umount "${DN_ROOTFS_DEBIAN}/var/cache/apt/archives"

    if [ "${ISCROSS}" = "1" ]; then
        unregister_qemuarm
    fi
}

kali_rootfs_linuxkernel() {
    # compile and install linux kernel for Raspberry Pi 2, install rpi2 specified tools

    if [[ -f "${PREFIX_TMP}-FLG_KERNEL_COMPILE_CORE" ]]; then
        echo "[DBG] SKIP compile kernel core"

    else
        # compile linux kernel for Raspberry Pi 2
        #make clean
        make -j $MACHINECORES
        RET=$?
        if [ ! "${RET}" = "0" ]; then
            echo "compiling linux kernel return $RET"
            echo "Error in compiling linux kernel"
            exit 1
        fi
        make -j $MACHINECORES modules
        if [ ! "$?" = "0" ]; then
            echo "Error in compiling linux kernel modules"
            exit 1
        fi

        my0_check_valid_path "${DN_ROOTFS_KERNEL}"
        sudo chown -R ${USER} "${DN_ROOTFS_KERNEL}"
        # install kernel
        make -j $MACHINECORES modules_install INSTALL_MOD_PATH="${DN_ROOTFS_KERNEL}"
        if [ "$?" = "0" ]; then
            touch "${PREFIX_TMP}-FLG_KERNEL_COMPILE_CORE"
        else
            echo "Error in installing  linux kernel modules"
            exit 1
        fi
    fi

    my0_check_valid_path "${DN_ROOTFS_KERNEL}"
    sudo mkdir -p "${DN_ROOTFS_KERNEL}/lib/"
    sudo chown -R ${USER} "${DN_ROOTFS_KERNEL}/lib/"
    sudo rm -rf ${DN_ROOTFS_KERNEL}/lib/firmware
    #git clone --depth 1 https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git ${DN_ROOTFS_KERNEL}/lib/firmware
    cp -r ${srcdir}/firmware-linux-git ${DN_ROOTFS_KERNEL}/lib/firmware
    rm -rf ${DN_ROOTFS_KERNEL}/lib/firmware/.git

if [ 1 = 0 ]; then
    make uImage
    make dtbs
    sudo mkdir -p "${DN_BOOT_4KERNEL}/dtbs/"
    sudo cp arch/arm/boot/uImage "${DN_BOOT_4KERNEL}/"
    sudo cp arch/arm/boot/dts/meson8b_odroidc.dtb "${DN_BOOT_4KERNEL}/dtbs/"

else
    my0_check_valid_path "${DN_ROOTFS_KERNEL}"
    sudo mkdir -p "${DN_BOOT_4KERNEL}"
    sudo chown -R ${USER} "${DN_BOOT_4KERNEL}"
    cp -rf ${srcdir}/firmware-raspberrypi-git/boot/* ${DN_BOOT_4KERNEL}

    cp arch/arm/boot/zImage ${DN_BOOT_4KERNEL}/${FN_RPI_KERNEL}

    cat << EOF > ${DN_BOOT_4KERNEL}/cmdline.txt
dwc_otg.lpm_enable=0 console=ttyAMA0,115200 kgdboc=ttyAMA0,115200 console=tty1 elevator=deadline root=/dev/mmcblk0p2 rootfstype=ext4 rootwait
EOF
    # rpi-wiggle
    mkdir -p ${DN_ROOTFS_KERNEL}/scripts
    #wget https://raw.github.com/dweeber/rpiwiggle/master/rpi-wiggle -O ${DN_ROOTFS_KERNEL}/scripts/rpi-wiggle.sh
    cp ${srcdir}/rpiwiggle-git/rpi-wiggle ${DN_ROOTFS_KERNEL}/scripts/rpi-wiggle.sh
    chmod 755 ${DN_ROOTFS_KERNEL}/scripts/rpi-wiggle.sh
fi

    sudo chown -R root:root "${DN_ROOTFS_KERNEL}"
}

rsync_and_verify() {
    PARAM_DN_SRC="$1"
    shift
    PARAM_DN_DST="$1"
    shift

    OPTS_OTHER="--devices --specials --acls --xattrs --sparse"

    sudo rsync -HPavz ${OPTS_OTHER} -q "${PARAM_DN_SRC}" "${PARAM_DN_DST}"

if [ 1 = 0 ]; then
    # verify the files
    cd "${PARAM_DN_SRC}/"
    sudo find . -type f | sudo xargs -n 1 md5sum > "${PREFIX_TMP}-md5sum-root"
    cd -
    cd "${PARAM_DN_DST}"
    sudo md5sum -c "${PREFIX_TMP}-md5sum-root"
    RET=$?
    cd -
    if [ "$RET" = "1" ]; then
        # error
        echo "Error in rootfs" >> "${FN_LOG}"
        exit 1
    fi
fi
}

# create a image file with two partitions: /boot/ and /
kali_create_image() {
    PARAM_DN_ROOTFS_DEBIAN="$1"
    shift
    PARAM_DN_ROOTFS_KERNEL="$1"
    shift

    # Create the disk and partition it
    if [[ ! -f "${FN_IMAGE}" || ! -f "${PREFIX_TMP}-FLG_KALI_CREATE_IMAGE" ]]; then
        echo "Creating image file for ${pkgdesc}: ${FN_IMAGE}"
        dd if=/dev/zero of=${FN_IMAGE} bs=1M count=${IMGCONTAINER_SIZE}
        if [ ! "$?" = "0" ]; then
            echo "error in dd"
            exit 1
        fi
        parted ${FN_IMAGE} --script -- mklabel msdos
        if [ ! "$?" = "0" ]; then
            echo "error in parted"
            exit 1
        fi
        #parted ${FN_IMAGE} --script -- mkpart primary fat32  0 64
        #parted ${FN_IMAGE} --script -- mkpart primary ext4  64 -1
        parted ${FN_IMAGE} --script -- mkpart primary fat32   2048s 264191s
        parted ${FN_IMAGE} --script -- mkpart primary ext4  264192s    100%

        #install_hardkernel_uboot ${FN_IMAGE}

        touch "${PREFIX_TMP}-FLG_KALI_CREATE_IMAGE"
    else
        echo "[DBG] SKIP creating image file ${FN_IMAGE}"
    fi

if [[ ! -f "${PREFIX_TMP}-FLG_FORMAT_IMAGE" || ! -f "${PREFIX_TMP}-FLG_RSYNC_ROOTFS" || ! -f "${PREFIX_TMP}-FLG_RSYNC_KERNEL" ]]; then
    # Set the partition variables
    DEV_LOOP=$(sudo losetup -f --show ${FN_IMAGE})
    if [ "${DEV_LOOP}" = "" ]; then
        echo "error in losetup"
        exit 1
    fi
    LOOPNAME=$(sudo kpartx -va ${DEV_LOOP} | sed -E 's/.*(loop[0-9])p.*/\1/g' | head -1)
    if [ "${LOOPNAME}" = "" ]; then
        echo "Error in loop device"
        exit 1
    fi
    #partprobe "${DEV_LOOP}" # to get /dev/loop0p1 ...
    bootp="/dev/mapper/${LOOPNAME}p1"
    rootp="/dev/mapper/${LOOPNAME}p2"

    if [[ -f "${PREFIX_TMP}-FLG_FORMAT_IMAGE" ]]; then
        echo "[DBG] SKIP rsync rootfs"

    else
        echo "Create file systems"
        sudo mkfs.vfat -n ${DISKLABEL_BOOTFS} $bootp
        if [ ! "$?" = "0" ]; then
            echo "error in format boot"
            exit 1
        fi
        sudo mkfs.ext4 -F -O ^has_journal -E stride=2,stripe-width=1024 -b 4096 -L ${DISKLABEL_ROOTFS} $rootp
        if [ ! "$?" = "0" ]; then
            echo "error in format root"
            exit 1
        fi
        touch "${PREFIX_TMP}-FLG_FORMAT_IMAGE"
    fi

    # Create the dirs for the partitions and mount them
    DN_ROOT="${srcdir}/mntrootfs-${MACHINEARCH}-${pkgname}"
    mkdir -p ${DN_ROOT}
    sudo mount $rootp ${DN_ROOT}
    if [ ! "$?" = "0" ]; then
        echo "error in mount root"
        exit 1
    fi

    DN_BOOT_4IMAGE="${DN_ROOT}${MNTPOINT_BOOT_FIRMWARE}"
    sudo mkdir -p ${DN_BOOT_4IMAGE}
    if [ ! "$?" = "0" ]; then
        echo "error in mkdir ${DN_BOOT_4IMAGE}"
        exit 1
    fi
    sudo mount $bootp ${DN_BOOT_4IMAGE}
    if [ ! "$?" = "0" ]; then
        echo "error in mount boot"
        exit 1
    fi

    if [[ -f "${PREFIX_TMP}-FLG_RSYNC_ROOTFS" ]]; then
        echo "[DBG] SKIP rsync rootfs"

    else
        echo "Rsyncing rootfs into image file"
        rsync_and_verify "${PARAM_DN_ROOTFS_DEBIAN}/" ${DN_ROOT}/
        touch "${PREFIX_TMP}-FLG_RSYNC_ROOTFS"
    fi

    if [[ -f "${PREFIX_TMP}-FLG_RSYNC_KERNEL" ]]; then
        echo "[DBG] SKIP rsync rootfs"

    else
        echo "Rsyncing kernel into image file"
        rsync_and_verify "${PARAM_DN_ROOTFS_KERNEL}/" ${DN_ROOT}/
        touch "${PREFIX_TMP}-FLG_RSYNC_KERNEL"
    fi

    # Enable login over serial
if [ 1 = 1 ]; then
    echo "echo 'T0:23:respawn:/sbin/agetty -L ttyAMA0 115200 vt100' >> ${DN_ROOT}/etc/inittab" | sudo sh
else
    echo "echo 'T0:123:respawn:/sbin/getty -L ttyS0 115200 vt100' >> ${DN_ROOT}/etc/inittab" | sudo sh
fi

    # if use hdr, uncomment following
    #ROOT_UUID=$(blkid $rootp | sed -n 's/.*UUID=\"\([^\"]*\)\".*/\1/p')
    #sed -i -e "s/root=[^\w ]*/root=${ROOT_UUID}/" "${DN_BOOT_4IMAGE}/boot.int"

    # Unmount partitions
    sudo umount ${DN_BOOT_4IMAGE}
    sudo umount ${DN_ROOT}
    sudo kpartx -dv ${DEV_LOOP}
    sudo losetup -d ${DEV_LOOP}
    if [ ! "$?" = "0" ]; then
        echo "error in losetup"
        exit 1
    fi

    # If you're building an image for yourself, comment all of this out, as you
    # don't need the sha1sum or to compress the image, since you will be testing it
    # soon.
    echo "Generating sha1sum for ${FN_IMAGE}"
    (cd $(dirname ${FN_IMAGE}) && sha1sum $(basename ${FN_IMAGE}) > ${FN_IMAGE}.sha1sum)
    if which bmaptool; then
        bmaptool create -o ${FN_IMAGE}.bmap ${FN_IMAGE}
    else if which pixz; then
        # Don't pixz on 32bit, there isn't enough memory to compress the images.
        HW=$(uname -m)
        if [ ${HW} == 'x86_64' ]; then
            echo "Compressing ${FN_IMAGE}"
            pixz ${FN_IMAGE} ${FN_IMAGE}.xz
            if [ "$?" = "0" ]; then
                rm -f ${FN_IMAGE}
                echo "Generating sha1sum for ${FN_IMAGE}.xz"
                (cd $(dirname ${FN_IMAGE}.xz) && sha1sum $(basename ${FN_IMAGE}.xz) > ${FN_IMAGE}.xz.sha1sum)
            fi
        fi
    fi fi

fi
}

my0_getpath () {
  PARAM_DN="$1"
  shift
  #readlink -f
  DN="${PARAM_DN}"
  FN=
  if [ ! -d "${DN}" ]; then
    FN=$(basename "${DN}")
    DN=$(dirname "${DN}")
  fi
  cd "${DN}" > /dev/null 2>&1
  DN=$(pwd)
  cd - > /dev/null 2>&1
  echo "${DN}/${FN}"
}

my0_check_valid_path() {
    V=$(my0_getpath "$1")
    if [[ "${V}" = "" || "${V}" = "/" ]]; then
        echo "Error: not set path variable: $1"
        exit 1
    fi
}

my_setevn() {
    # setup environments
    MACHINE=${ARCHITECTURE}
    ISCROSS=1
    HW=$(uname -m)
    case ${HW} in
    armv5el)
        # Pi 1
        ISCROSS=0
        MACHINE=armel
        ;;
    armv7l)
        # Pi 2
        ISCROSS=0
        MACHINE=armhf
        ;;
    x86_64)
        ;;
    esac
    export MACHINEARCH="${MACHINE}"

    MACHINECORES=$(grep -c processor /proc/cpuinfo)
    if [ "$MACHINECORES" = "" ]; then
        MACHINECORES=2
    fi

    export FN_IMAGE="${srcdir}/${pkgname}-${pkgver}-${MACHINEARCH}.img"

    #export DN_TOOLCHAIN_UBOOT="${srcdir}/toolchains-uboot-${MACHINEARCH}"
    #export DN_TOOLCHAIN_KERNEL="${srcdir}/toolchains-kernel-${MACHINEARCH}"
    export DN_TOOLCHAIN_UBOOT="${srcdir}/"
    export DN_TOOLCHAIN_KERNEL="${srcdir}/"

    DN_ROOTFS_KERNEL="${srcdir}/rootfs-kernel-${MACHINEARCH}-${pkgname}"
    DN_BOOT_4KERNEL="${DN_ROOTFS_KERNEL}${MNTPOINT_BOOT_FIRMWARE}"
    DN_ROOTFS_DEBIAN="${srcdir}/rootfs-kali-${MACHINEARCH}-${pkgname}"

    export ARCH=arm
    if [ "${ISCROSS}" = "1" ]; then
        if [ $(uname -m) = x86_64 ]; then
            export DN_TOOLCHAIN_KERNEL="${srcdir}/tools-raspberrypi-git/"
            export PATH=${DN_TOOLCHAIN_KERNEL}/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin/:$PATH
            export CROSS_COMPILE=arm-linux-gnueabihf-
        else
            export DN_TOOLCHAIN_KERNEL="${srcdir}/tools-raspberrypi-git/"
            export PATH=${DN_TOOLCHAIN_KERNEL}/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin/:$PATH
            export CROSS_COMPILE=arm-linux-gnueabihf-
        fi
    else
        export CROSS_COMPILE=
        unset CROSS_COMPILE
    fi

    mkdir -p "${DN_ROOTFS_KERNEL}"
    mkdir -p "${DN_BOOT_4KERNEL}"
    mkdir -p "${DN_ROOTFS_DEBIAN}"
    my0_check_valid_path "${DN_ROOTFS_KERNEL}"
    my0_check_valid_path "${DN_BOOT_4KERNEL}"
    my0_check_valid_path "${DN_ROOTFS_DEBIAN}"
}

prepare_rpi2_kernel () {
    # linux kernel for Raspberry Pi 2
    cd "${srcdir}/${DNSRC_LINUX}"
    if [ "${USE_GIT_REPO}" = "1" ]; then
        git submodule init
        git submodule update
        git pull --all
    fi

    patch -p1 --no-backup-if-mismatch < ${srcdir}/${PATCH_MAC80211}
    if [ ! "$?" = "0" ]; then
        echo "error in patch ${PATCH_MAC80211}"
        exit 1
    fi
    touch .scmversion

    #make mrproper
    make ${MAKE_CONFIG} # generate .config
    cp ${srcdir}/${CONFIG_KERNEL} .config # or use ours
    patch -p0 --no-backup-if-mismatch < ${srcdir}/${PATCH_CONFIG_KERNEL}
    if [ ! "$?" = "0" ]; then
        echo "error in patch ${PATCH_CONFIG_KERNEL}"
        exit 1
    fi

    #make modules_prepare
    #cp "${srcdir}/firmware-raspberrypi-git/extra/Module.symvers" . # copy Module.sysmvers to the linux directory
}

prepare_rpi2_rootfs () {

    # Set up firmware config
    cat << EOF > ${DN_BOOT_4KERNEL}/config.txt
# For more options and information see 
# http://www.raspberrypi.org/documentation/configuration/config-txt.md
# Some settings may impact device functionality. See link above for details

# uncomment if you get no picture on HDMI for a default "safe" mode
#hdmi_safe=1

# uncomment this if your display has a black border of unused pixels visible
# and your display can output without overscan
#disable_overscan=1

# uncomment the following to adjust overscan. Use positive numbers if console
# goes off screen, and negative if there is too much border
#overscan_left=16
#overscan_right=16
#overscan_top=16
#overscan_bottom=16

# uncomment to force a console size. By default it will be display's size minus
# overscan.
#framebuffer_width=1280
#framebuffer_height=720

# uncomment if hdmi display is not detected and composite is being output
#hdmi_force_hotplug=1

# uncomment to force a specific HDMI mode (this will force VGA)
#hdmi_group=1
#hdmi_mode=1

# uncomment to force a HDMI mode rather than DVI. This can make audio work in
# DMT (computer monitor) modes
#hdmi_drive=2

# uncomment to increase signal to HDMI, if you have interference, blanking, or
# no display
#config_hdmi_boost=4

# uncomment for composite PAL
#sdtv_mode=2

#uncomment to overclock the arm. 700 MHz is the default.
#arm_freq=800
EOF
    ln -sf firmware/config.txt "${DN_ROOTFS_KERNEL}/boot/config.txt"
    echo 'dwc_otg.lpm_enable=0 console=tty1 root=/dev/mmcblk0p2 rootwait' > ${DN_BOOT_4KERNEL}/cmdline.txt
    ln -sf firmware/cmdline.txt "${DN_ROOTFS_KERNEL}/boot/cmdline.txt"

    # Load sound module on boot
    cat << EOF > "${DN_ROOTFS_DEBIAN}/lib/modules-load.d/rpi2.conf"
snd_bcm2835
bcm2708_rng
EOF

    # Blacklist platform modules not applicable to the RPi2
    cat << EOF > "${DN_ROOTFS_KERNEL}/etc/modprobe.d/rpi2.conf"
blacklist snd_soc_pcm512x_i2c
blacklist snd_soc_pcm512x
blacklist snd_soc_tas5713
blacklist snd_soc_wm8804
EOF

    cat << EOF > "${DN_ROOTFS_KERNEL}/etc/X11/xorg.conf"
# X.Org X server configuration file for xfree86-video-mali

Section "Device"
        Identifier      "Mali-Fbdev"
        Driver          "mali"
        Option          "fbdev"         "/dev/fb0"
        Option          "DRI2"            "true"
        Option          "DRI2_PAGE_FLIP"  "false"
        Option          "DRI2_WAIT_VSYNC" "false"
        Option          "UMP_CACHED"      "true"
        Option          "UMP_LOCK"        "false"
        Option          "SWCursor"        "true"
        Option          "HWCursor"        "false"
EndSection

Section "ServerFlags"
        Option          "NoTrapSignals" "true"
        Option          "DontZap"       "false"
        Option          "BlankTime"     "0"
        Option          "StandbyTime"   "0"
        Option          "SuspendTime"   "0"
        Option          "OffTime"       "0"
EndSection

Section "DRI"
        Mode            0666
EndSection
EOF

    cat << EOF > "${DN_ROOTFS_KERNEL}/etc/X11/xorg.conf.failsafe"
Section "Device"
	Identifier	"Configured Video Device"
	Driver		"vesa"
EndSection

Section "Monitor"
	Identifier	"Configured Monitor"
EndSection

Section "Screen"
	Identifier	"Default Screen"
	Monitor		"Configured Monitor"
	Device		"Configured Video Device"
EndSection
EOF

}

prepare() {
    my_setevn
    #rm -f "${FN_IMAGE}" ${PREFIX_TMP}*

    rm -rf ${DN_BOOT_4KERNEL}
    rm -rf ${DN_ROOTFS_KERNEL}
    #rm -rf ${DN_ROOTFS_DEBIAN}
    mkdir -p ${DN_BOOT_4KERNEL}
    mkdir -p ${DN_ROOTFS_KERNEL}
    mkdir -p ${DN_ROOTFS_DEBIAN}

    prepare_rpi2_kernel

    echo "Build rootfs ..."
    cd ${srcdir}
    # create rootfs
    kali_rootfs_debootstrap
    prepare_rpi2_rootfs
    echo "Build rootfs DONE!"
}

build() {
    my_setevn

    export ARCH=arm
    if [ "${ISCROSS}" = "1" ]; then
        if [ $(uname -m) = x86_64 ]; then
            export DN_TOOLCHAIN_KERNEL="${srcdir}/tools-raspberrypi-git/"
            export PATH=${DN_TOOLCHAIN_KERNEL}/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin/:$PATH
            export CROSS_COMPILE=arm-linux-gnueabihf-
        else
            export DN_TOOLCHAIN_KERNEL="${srcdir}/tools-raspberrypi-git/"
            export PATH=${DN_TOOLCHAIN_KERNEL}/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin/:$PATH
            export CROSS_COMPILE=arm-linux-gnueabihf-
        fi
    else
        export CROSS_COMPILE=
        unset CROSS_COMPILE
    fi
    echo "Build Linux kernel ..."
    cd "${srcdir}/${DNSRC_LINUX}"
    kali_rootfs_linuxkernel
    echo "Build Linux kernel DONE!"
}

package() {
    my_setevn

    kali_create_image "${DN_ROOTFS_DEBIAN}" "${DN_ROOTFS_KERNEL}"

    cd ${srcdir}
    #make DESTDIR="$pkgdir/" install
    mkdir -p "${pkgdir}/usr/share/${pkgname}"
    cp ${FN_IMAGE}* "${pkgdir}/usr/share/${pkgname}"
}
