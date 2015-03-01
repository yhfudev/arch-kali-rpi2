# Maintainer: Yunhui Fu <yhfudev at gmail dot com>

pkgname=kali-rpi2-git
pkgver=5c92661
pkgrel=1
pkgdesc="Raspberry Pi 2 image"
arch=('i686' 'x86_64' 'arm')
url="https://github.com/yhfudev/arch-kali-rpi2.git"
license=('GPL')
depends=('gcc-libs' 'bash' 'libncurses-dev')
makedepends=('git')
provides=('kali-rpi2-git')
conflicts=('kali-rpi2')
#install="$pkgname.install"
#PKGEXT=.pkg.tar.xz

NAME_SHORT=${pkgname}
source=(
        #"linux-${NAME_SHORT}::git+https://github.com/raspberrypi/linux.git"
        "tools-${NAME_SHORT}::git+https://github.com/raspberrypi/tools.git"
        "rpi-firmware::git+https://github.com/raspberrypi/firmware.git"
        "firmware::git+https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git"
        "kali-arm-build-scripts::git+https://github.com/yhfudev/kali-arm-build-scripts.git"
        "mac80211.patch::https://raw.github.com/offensive-security/kali-arm-build-scripts/master/patches/kali-wifi-injection-3.12.patch"
        "rpi2-3.19.config"
        )

md5sums=(
         #'SKIP'
         'SKIP'
         'SKIP'
         'SKIP'
         'SKIP'
         'e75b1d15337cd2ee41eefe4a1c876d34'
         '9d360e001ac70a6d1bdee6d43f7e2268'
         )
shasums=(
         #'SKIP'
         'SKIP'
         'SKIP'
         'SKIP'
         'SKIP'
         '3103bd17ca4cb7c80fccd5194386177a7b3f0254'
         '8efb8c902cc9e9688f290c9b331eee163e765b3c'
         )

pkgver() {
    cd "$srcdir/$pkgname"
    local ver="$(git show | grep commit | awk '{print $2}'  )"
    #printf "r%s" "${ver//[[:alpha:]]}"
    echo ${ver:0:7}
}

prepare() {
    cd "$srcdir/$pkgname"
    #cd "${srcdir}/${pkgname}-${pkgver}"
    #patch -p0 < "$srcdir/libucd-fix.patch"
}

build() {
    cd "$srcdir/$pkgname"
    #cd "${srcdir}/${pkgname}-${pkgver}"
    ./autogen.sh
    ./configure --prefix=/usr --sysconfdir=/etc --mandir=/usr/share/man --disable-static --disable-icu
    make
}

package() {
    cd "$srcdir/$pkgname"
    #cd "${srcdir}/${pkgname}-${pkgver}"
    make DESTDIR="$pkgdir/" install
}
