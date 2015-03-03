#!/bin/bash

DANGER_EXEC=
MYEXEC=

#set MYEXEC to echo for dry run
#MYEXEC="echo [DryRun]"

FN_LOG=/dev/stderr

BASEDIR=$(pwd)

# import config file
if [ -f "/etc/makepkg.conf" ]; then
. /etc/makepkg.conf
fi

if [ "${PKGDEST}" = "" ]; then
    PKGDEST="${BASEDIR}/pkg/"
fi
if [ "${SRCDEST}" = "" ]; then
    SRCDEST="${BASEDIR}/src/"
fi
if [ "${SRCPKGDEST}" = "" ]; then
    SRCPKGDEST="${BASEDIR}/"
fi

read_user_config () {
    PARAM_FN="$1"
    . "${PARAM_FN}"
}

#NAME_SHORT=rpi

#source=(
        #"linux-${NAME_SHORT}::git+https://github.com/raspberrypi/linux.git"
        #"tools-${NAME_SHORT}::git+https://github.com/raspberrypi/tools.git"
        #"rpi-firmware::git+https://github.com/raspberrypi/firmware.git"
        #)

gen_detect_url () {
    PARAM_FN_AWK=$1
    if [ "${PARAM_FN_AWK}" = "" ]; then
        PARAM_FN_AWK="${FN_AWK_DET_URL}"
    fi

    cat << EOF > "${PARAM_FN_AWK}"
#!/usr/bin/awk
# split info from download URL
# Copyright 2015 Yunhui Fu
# License: GPL v3.0 or later

BEGIN {
    FN_OUTPUT=FNOUT
    if ("" == FN_OUTPUT) {
        FN_OUTPUT="guess-linux-dist-output-url"
        print "[DBG] Waring: use the default output file name: " FN_OUTPUT;
        print "[DBG]         please specify the output file name via 'awk -v FNOUT=outfile'";
    }
    dist_tool="wget";
    dist_url="";
    dist_rename="";
}
{
    # process url, such as "http://sample.com/path/to/unix-i386.iso"
    split (\$0, a, ":");
    if (length(a) < 2) {
        # local file
        dist_tool="local";
        dist_url=\$0;
        dist_rename=\$0;

    } else if (length(a) > 2) {
        dist_rename=a[1];
        split (a[3], b, "+");
        if (length(b) > 1) {
            dist_tool=b[1];
            dist_url=b[2] ":" a[4];
        } else {
            dist_tool="wget";
            dist_url=a[3] ":" a[4];
        }
    } else {
        # == 2
        split (a[1], b, "+");
        if (length(b) > 1) {
            dist_tool=b[1];
            dist_url=b[2] ":" a[2];
        } else {
            dist_tool="wget";
            dist_url=a[1] ":" a[2];
            dist_rename="\$(basename " a[1] ":" a[2] ")";
        }
    }
}

END {
    #print "[DBG]" \
        #" dist_tool=" (""==dist_tool?"unknown":dist_tool) \
        #" dist_url=" (""==dist_url?"unknown":dist_url) \
        #" dist_rename=" (""==dist_rename?"unknown":dist_rename) \
        #;
    print "DECLNXOUT_TOOL="   dist_tool    > FN_OUTPUT
    print "DECLNXOUT_URL="    dist_url    >> FN_OUTPUT
    print "DECLNXOUT_RENAME=" dist_rename >> FN_OUTPUT
}
EOF
}

FN_OUT=/tmp/addowe35d.tmp
FN_AWK_DET_URL=/tmp/asdfasd.awk
clear_detect_url() {
    rm -f "${FN_AWK_DET_URL}" "${FN_OUT}"
}

detect_url() {
    PARAM_RAWURL="$1"
    if [ "${PARAM_RAWURL}" = "" ]; then
        echo "[DBG] internal parameter error!" >> "${FN_LOG}"
        exit 1
    fi

    DECLNXOUT_TOOL=wget
    DECLNXOUT_URL=
    DECLNXOUT_RENAME=

    if [ ! -f "${FN_AWK_DET_URL}" ]; then
        gen_detect_url "${FN_AWK_DET_URL}"
    fi
    echo "${PARAM_RAWURL}" | gawk -v FNOUT=${FN_OUT} -f "${FN_AWK_DET_URL}"
    if [ -f "${FN_OUT}" ]; then
        . "${FN_OUT}"
    fi
}

check_xxxsum_ok () {
    PARAM_DNFILE=$1
    shift
    PARAM_FNBASE=$1
    shift
    PARAM_CNT=$1
    shift
    PATH_FILE="${PARAM_FNBASE}"
    if [ ! "${PARAM_DNFILE}" = "" ]; then
        PATH_FILE="${PARAM_DNFILE}/${PARAM_FNBASE}"
    fi

    FLG_ERROR=1
#echo "[DBG] checking if file exist: ${PATH_FILE}" >> "${FN_LOG}"
    if [ -f "${PATH_FILE}" ]; then
#echo "[DBG] file exist: ${PATH_FILE}" >> "${FN_LOG}"
        FLG_ERROR=0
        if [[ ${#md5sums[*]} > ${PARAM_CNT} ]]; then
            if [ ! "${md5sums[${PARAM_CNT}]}" = "SKIP" ]; then
                MD5SUM=$(md5sum "${PATH_FILE}" | awk '{print $1}')
                if [ ! "${MD5SUM}" = "${md5sums[${PARAM_CNT}]}" ]; then
                    FLG_ERROR=1
                    echo "[DBG] file md5sum error: ${PATH_FILE}" >> "${FN_LOG}"
                    echo "[DBG] file md5sum=${MD5SUM}; md5[${PARAM_CNT}]=${md5sums[${PARAM_CNT}]}" >> "${FN_LOG}"
                fi
            fi
        fi
        
        if [[ ${#sha1sums[*]} > ${PARAM_CNT} ]]; then
            if [ ! "${sha1sums[${PARAM_CNT}]}" = "SKIP" ]; then
                SHASUM=$(shasum "${PATH_FILE}" | awk '{print $1}')
                if [ ! "${SHASUM}" = "${sha1sums[${PARAM_CNT}]}" ]; then
                    FLG_ERROR=1
                    echo "[DBG] file sha1sums error: ${PATH_FILE}" >> "${FN_LOG}"
                    echo "[DBG] file sha1sums=${SHASUM}; sha[${PARAM_CNT}]=${sha1sums[${PARAM_CNT}]}" >> "${FN_LOG}"
                fi
            fi
        fi
        if [[ ${#sha256sums[*]} > ${PARAM_CNT} ]]; then
            if [ ! "${sha256sums[${PARAM_CNT}]}" = "SKIP" ]; then
                SHASUM=$(sha256sum "${PATH_FILE}" | awk '{print $1}')
                if [ ! "${SHASUM}" = "${sha256sums[${PARAM_CNT}]}" ]; then
                    FLG_ERROR=1
                    echo "[DBG] file sha256sums error: ${PATH_FILE}" >> "${FN_LOG}"
                    echo "[DBG] file sha256sums=${SHASUM}; sha[${PARAM_CNT}]=${sha256sums[${PARAM_CNT}]}" >> "${FN_LOG}"
                fi
            fi
        fi
        if [[ ${#sha384sums[*]} > ${PARAM_CNT} ]]; then
            if [ ! "${sha384sums[${PARAM_CNT}]}" = "SKIP" ]; then
                SHASUM=$(sha384sum "${PATH_FILE}" | awk '{print $1}')
                if [ ! "${SHASUM}" = "${sha384sums[${PARAM_CNT}]}" ]; then
                    FLG_ERROR=1
                    echo "[DBG] file sha384sums error: ${PATH_FILE}" >> "${FN_LOG}"
                    echo "[DBG] file sha384sums=${SHASUM}; sha[${PARAM_CNT}]=${sha384sums[${PARAM_CNT}]}" >> "${FN_LOG}"
                fi
            fi
        fi
        if [[ ${#sha512sums[*]} > ${PARAM_CNT} ]]; then
            if [ ! "${sha512sums[${PARAM_CNT}]}" = "SKIP" ]; then
                SHASUM=$(sha512sum "${PATH_FILE}" | awk '{print $1}')
                if [ ! "${SHASUM}" = "${sha512sums[${PARAM_CNT}]}" ]; then
                    FLG_ERROR=1
                    echo "[DBG] file sha512sums error: ${PATH_FILE}" >> "${FN_LOG}"
                    echo "[DBG] file sha512sums=${SHASUM}; sha[${PARAM_CNT}]=${sha512sums[${PARAM_CNT}]}" >> "${FN_LOG}"
                fi
            fi
        fi
    fi
    if [ "${FLG_ERROR}" = "1" ]; then
        echo "false"
    else
        echo "true"
    fi
}

down_sources() {
    ${MYEXEC} mkdir -p "${SRCPKGDEST}"
    clear_detect_url
    CNT=0
    #for i in ${source[*]} ; do
    while [[ $CNT < ${#source[*]} ]] ; do
        i=${source[$CNT]}
        echo "[DBG] down url=$i" >> "${FN_LOG}"
        detect_url "$i"
        if [ "${DECLNXOUT_TOOL}" = "" ]; then
            echo "Error: no tool" >> "${FN_LOG}"
            exit 0
        fi
        if [ "${DECLNXOUT_URL}" = "" ]; then
            echo "Error: no url" >> "${FN_LOG}"
            exit 0
        fi
        if [ "${DECLNXOUT_RENAME}" = "" ]; then
            echo "Error: no target path" >> "${FN_LOG}"
            exit 0
        fi
        #echo "TOOL=${DECLNXOUT_TOOL}; URL=${DECLNXOUT_URL}; rename=${DECLNXOUT_RENAME}; " >> "${FN_LOG}"
        case ${DECLNXOUT_TOOL} in
        git)
            DN0=$(pwd)
            cd "${SRCPKGDEST}"
            if [ -d "${DECLNXOUT_RENAME}" ]; then
                cd "${DECLNXOUT_RENAME}"
                echo "[DBG] try git pull ..."
                ${MYEXEC} git pull
                cd -
            else
                echo "[DBG] try git clone --no-checkout ${DECLNXOUT_URL} ${DECLNXOUT_RENAME} ..."
                ${MYEXEC} git clone --no-checkout "${DECLNXOUT_URL}" ${DECLNXOUT_RENAME}
                cd ${DECLNXOUT_RENAME}
                ${MYEXEC} echo "for branch in \$(git branch -a | grep remotes | grep -v HEAD | grep -v master); do git branch --track \${branch##*/} \$branch ; done" | ${MYEXEC} bash
                ${MYEXEC} git fetch --all
                ${MYEXEC} git pull --all
                cd -
            fi
            cd ${DN0}
            ;;
        hg)
            DN0=$(pwd)
            cd "${SRCPKGDEST}"
            if [ -d "${DECLNXOUT_RENAME}" ]; then
                cd "${DECLNXOUT_RENAME}"
                echo "[DBG] try hg pull ..."
                ${MYEXEC} hg pull
                cd -
            else
                echo "[DBG] try hg clone --no-checkout ${DECLNXOUT_URL} ${DECLNXOUT_RENAME} ..."
                ${MYEXEC} hg clone --no-checkout "${DECLNXOUT_URL}" ${DECLNXOUT_RENAME}
            fi
            cd ${DN0}
            ;;
        svn)
            DN0=$(pwd)
            cd "${SRCPKGDEST}"
            if [ -d "${DECLNXOUT_RENAME}" ]; then
                cd "${DECLNXOUT_RENAME}"
                echo "[DBG] try svn update ..."
                ${MYEXEC} svn update
                cd -
            else
                echo "[DBG] try svn checkout ${DECLNXOUT_URL} ${DECLNXOUT_RENAME} ..."
                ${MYEXEC} svn checkout "${DECLNXOUT_URL}" ${DECLNXOUT_RENAME}
            fi
            cd ${DN0}
            ;;
        wget|local)
            FNDOWN="${DECLNXOUT_RENAME}"
            if [ "${FNDOWN}" = "" ]; then
                FNDOWN=$(echo "${DECLNXOUT_URL}" | awk -F? '{print $1}' | xargs basename)
            fi
            if [ "${DECLNXOUT_TOOL}" = "wget" ]; then
#echo "[DBG] check wget file: ${FNDOWN}" >> "${FN_LOG}"
                FLG_OK=$(check_xxxsum_ok "${SRCPKGDEST}" "${FNDOWN}" ${CNT})
            else
#echo "[DBG] check local file: ${FNDOWN}" >> "${FN_LOG}"
                FLG_OK=$(check_xxxsum_ok "" "${FNDOWN}" ${CNT})
            fi
            if [ "${FLG_OK}" = "false" ]; then
                echo "[DBG] DECLNXOUT_RENAME=${DECLNXOUT_RENAME}, FNDOWN=${FNDOWN}" >> "${FN_LOG}"
                if [ "${DECLNXOUT_TOOL}" = "wget" ]; then
                    ${MYEXEC} wget -O "${SRCPKGDEST}/${FNDOWN}" "${DECLNXOUT_URL}"
                else
                    echo "Error in checking file: ${DECLNXOUT_RENAME}" >> "${FN_LOG}"
                    exit 1
                fi
#else echo "[DBG] check file ok: ${FNDOWN}" >> "${FN_LOG}"
            fi
            ;;
        *)
            DN0=$(pwd)
            cd "${SRCPKGDEST}"
            echo "[DBG] try ${DECLNXOUT_TOOL} ${DECLNXOUT_URL} ${DECLNXOUT_RENAME} ..."
            ${MYEXEC} ${DECLNXOUT_TOOL} "${DECLNXOUT_URL}" ${DECLNXOUT_RENAME}
           cd ${DN0}
            ;;
        esac
        CNT=$(( ${CNT} + 1 ))
    done
}

checkout_sources() {
    if [ "${srcdir}/" = "/" ]; then
        echo "[DBG] not set repo pkg dir"
        exit 1
    else
        echo "DONT remove ${srcdir}/!"
    fi
    ${MYEXEC} mkdir -p "${srcdir}"
    clear_detect_url
    for i in ${source[*]} ; do
        echo "[DBG] checkout url=$i" >> "${FN_LOG}"
        detect_url "$i"
        if [ "${DECLNXOUT_TOOL}" = "" ]; then
            echo "Error: no tool" >> "${FN_LOG}"
            exit 0
        fi
        if [ "${DECLNXOUT_URL}" = "" ]; then
            echo "Error: no url" >> "${FN_LOG}"
            exit 0
        fi
        #if [ "${DECLNXOUT_RENAME}" = "" ]; then
            #echo "Error: no target path" >> "${FN_LOG}"
            #exit 0
        #fi
        #echo "TOOL=${DECLNXOUT_TOOL}; URL=${DECLNXOUT_URL}; rename=${DECLNXOUT_RENAME}; " >> "${FN_LOG}"
        FN_BASE="${DECLNXOUT_RENAME}"
        if [ "${FN_BASE}" = "" ]; then
            FN_FULL=$(echo "${DECLNXOUT_URL}" | awk -F? '{print $1}' | xargs basename)
            FN_BASE=$(echo "${FN_FULL}" | ${EXEC_AWK} -F. '{b=$1; for (i=2; i < NF; i ++) {b=b "." $(i)}; print b}')
        fi
        case ${DECLNXOUT_TOOL} in
        git)
            if [ -d "${srcdir}/${FN_BASE}" ]; then
                cd "${srcdir}/${FN_BASE}"
                echo "[DBG] try git 'revert' ..."
                #${MYEXEC} git ls-files | ${MYEXEC} xargs git checkout --
                ${MYEXEC} git status | grep "modified:" | awk '{print $2}' | ${MYEXEC} xargs git checkout --
                cd -
            else
                echo "[DBG] try git clone ${SRCPKGDEST}/${FN_BASE} ${srcdir}/${FN_BASE} ..."
                ${MYEXEC} git clone "${SRCPKGDEST}/${FN_BASE}" "${srcdir}/${FN_BASE}"
                #cd "${srcdir}/${FN_BASE}"
                #${MYEXEC} echo "for branch in \$(git branch -a | grep remotes | grep -v HEAD | grep -v master); do git branch --track \${branch##*/} \$branch ; done" | ${MYEXEC} bash
                #${MYEXEC} git fetch --all
                #${MYEXEC} git pull --all
                #cd -
            fi
            ;;
        hg)
            if [ -d "${srcdir}/${FN_BASE}" ]; then
                cd "${srcdir}/${FN_BASE}"
                echo "[DBG] try hg 'revert' ..."
                ${MYEXEC} hg update --clean
                ${MYEXEC} hg revert --all
                cd -
            else
                echo "[DBG] try hg clone ${SRCPKGDEST}/${FN_BASE} ${srcdir}/${FN_BASE} ..."
                ${MYEXEC} hg clone "${SRCPKGDEST}/${FN_BASE}" "${srcdir}/${FN_BASE}"
            fi
            ;;
        svn)
            if [ -d "${srcdir}/${FN_BASE}" ]; then
                cd "${srcdir}/${FN_BASE}"
                echo "[DBG] try svn 'revert' ..."
                ${MYEXEC} svn revert --recursive
                cd -
            else
                echo "[DBG] try cp -rp ${SRCPKGDEST}/${FN_BASE} ${srcdir}/${FN_BASE} ..."
                ${MYEXEC} cp -rp "${SRCPKGDEST}/${FN_BASE}" "${srcdir}/${FN_BASE}"
            fi
            ;;
        wget)
            FNDOWN=$(echo "${DECLNXOUT_RENAME}" | awk -F? '{print $1}' | xargs basename)
            ${MYEXEC} rm -f "${srcdir}/${FNDOWN}"
            ${MYEXEC} ln -s "${SRCPKGDEST}/${FNDOWN}" "${srcdir}/${FNDOWN}"
            ;;
        local)
            FNDOWN=$(echo "${DECLNXOUT_RENAME}" | awk -F? '{print $1}' | xargs basename)
            ${MYEXEC} rm -f "${srcdir}/${FNDOWN}"
            ${MYEXEC} ln -s "${BASEDIR}/${FNDOWN}" "${srcdir}/${FNDOWN}"
            ;;
        *)
            DN0=$(pwd)
            echo "[DBG] cp -rp ${SRCPKGDEST}/${FNDOWN} ${srcdir}/${FNDOWN} ..."
            ${MYEXEC} cp -rp "${SRCPKGDEST}/${FNDOWN}" "${srcdir}/${FNDOWN}"
            cd ${DN0}
            ;;
        esac
    done
}

makepkg_tarpkg() {
    cd "${pkgdir}"
    PREFIX="${pkgname}-$(uname -m)"
    type pkgver > /dev/null
    if [ "$?" = "0" ]; then
        PREFIX="${pkgname}-$(pkgver)-$(uname -m)"
    fi
    echo "[DBG] PREFIX=${PREFIX}"
    case ${PKGEXT} in
    *.tar.xz)
        ${MYEXEC} XZ_OPT=-9 tar -Jcf "${BASEDIR}/${PREFIX}.pkg.tar.xz" .
        ;;
    *.tar.bz2)
        ${MYEXEC} tar -jcf "${BASEDIR}/${PREFIX}.pkg.tar.bz2" .
        ;;
    *)
        ${MYEXEC} tar -zcf "${BASEDIR}/${PREFIX}.pkg.tar.gz" .
        ;;
    esac
}
PKGEXT=.pkg.tar.xz

prepare_env() {
    srcdir="${SRCDEST}/"
    pkgdir="${PKGDEST}/${pkgname}"

    echo "[DBG] mkdir for required dir ..."
    echo "[DBG] srcdir=${srcdir}"
    echo "[DBG] pkgdir=${pkgdir}"
    echo "[DBG] SRCPKGDEST=${SRCPKGDEST}"
    ${MYEXEC} mkdir -p "${srcdir}"
    ${MYEXEC} mkdir -p "${pkgdir}"
    ${MYEXEC} mkdir -p "${SRCPKGDEST}"
}

#NAME_SHORT=rpi

#source=(
        #"linux-${NAME_SHORT}::git+https://github.com/raspberrypi/linux.git"
        #"tools-${NAME_SHORT}::git+https://github.com/raspberrypi/tools.git"
        #"rpi-firmware::git+https://github.com/raspberrypi/firmware.git"
        #"firmware::git+https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git"
        #"mac80211.patch::https://raw.github.com/offensive-security/kali-arm-build-scripts/master/patches/kali-wifi-injection-3.12.patch"
        #"kali-arm-build-scripts::git+https://github.com/yhfudev/kali-arm-build-scripts.git"
        #)

#down_sources
#checkout_sources
