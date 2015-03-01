#!/bin/bash

DANGER_EXEC=
MYEXEC=

#set MYEXEC to echo for dry run
MYEXEC="echo [DryRun]"

FN_LOG=/dev/stderr

BASEDIR=$(pwd)

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
# try to guess the linux distribution from download URL
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

DN_REPO_SRC="${BASEDIR}/src"
DN_REPO_PKG="${BASEDIR}/pkg"

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
        if [[ ${#shasums[*]} > ${PARAM_CNT} ]]; then
            if [ ! "${shasums[${PARAM_CNT}]}" = "SKIP" ]; then
                SHASUM=$(shasum "${PATH_FILE}" | awk '{print $1}')
                if [ ! "${SHASUM}" = "${shasums[${PARAM_CNT}]}" ]; then
                    FLG_ERROR=1
                    echo "[DBG] file SHASUM error: ${PATH_FILE}" >> "${FN_LOG}"
                    echo "[DBG] file SHASUM=${SHASUM}; sha[${PARAM_CNT}]=${shasums[${PARAM_CNT}]}" >> "${FN_LOG}"
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
    ${MYEXEC} mkdir -p "${DN_REPO_SRC}"
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
        if [ -d "${DN_REPO_SRC}/${DECLNXOUT_RENAME}" ]; then
            echo "[DBG] skip dir ${DN_REPO_SRC}/${DECLNXOUT_RENAME}" >> "${FN_LOG}"
            CNT=$(( ${CNT} + 1 ))
            continue
        fi
        if [ -f "${DN_REPO_SRC}/${DECLNXOUT_RENAME}" ]; then
            echo "[DBG] skip file ${DN_REPO_SRC}/${DECLNXOUT_RENAME}" >> "${FN_LOG}"
            CNT=$(( ${CNT} + 1 ))
            continue
        fi
        case ${DECLNXOUT_TOOL} in
        git)
            cd "${DN_REPO_SRC}"
            ${MYEXEC} git clone --no-checkout "${DECLNXOUT_URL}" ${DECLNXOUT_RENAME}
            cd -
            ;;
        svn)
            cd "${DN_REPO_SRC}"
            ${MYEXEC} svn checkout "${DECLNXOUT_URL}" ${DECLNXOUT_RENAME}
            cd -
            ;;
        wget|local)
            FNDOWN="${DECLNXOUT_RENAME}"
            if [ "${FNDOWN}" = "" ]; then
                FNDOWN=$(echo "${DECLNXOUT_URL}" | awk -F? '{print $1}' | xargs basename)
            fi
            if [ "${DECLNXOUT_TOOL}" = "wget" ]; then
#echo "[DBG] check wget file: ${FNDOWN}" >> "${FN_LOG}"
                FLG_OK=$(check_xxxsum_ok "${DN_REPO_SRC}" "${FNDOWN}" ${CNT})
            else
#echo "[DBG] check local file: ${FNDOWN}" >> "${FN_LOG}"
                FLG_OK=$(check_xxxsum_ok "" "${FNDOWN}" ${CNT})
            fi
            if [ "${FLG_OK}" = "false" ]; then
                echo "[DBG] DECLNXOUT_RENAME=${DECLNXOUT_RENAME}, FNDOWN=${FNDOWN}" >> "${FN_LOG}"
                if [ "${DECLNXOUT_TOOL}" = "wget" ]; then
                    ${MYEXEC} wget -O "${DN_REPO_SRC}/${FNDOWN}" "${DECLNXOUT_URL}"
                else
                    echo "Error in checking file: ${DECLNXOUT_RENAME}" >> "${FN_LOG}"
                    exit 1
                fi
#else echo "[DBG] check file ok: ${FNDOWN}" >> "${FN_LOG}"
            fi
            ;;
        esac
        CNT=$(( ${CNT} + 1 ))
    done
}

checkout_sources() {
    if [ "${DN_REPO_PKG}/" = "/" ]; then
        echo "[DBG] not set repo pkg dir"
        exit 1
    else
        ${MYEXEC} ${DANGER_EXEC} rm -rf "${DN_REPO_PKG}/"
    fi
    ${MYEXEC} mkdir -p "${DN_REPO_PKG}"
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
            ${MYEXEC} git clone --depth 1 "${DN_REPO_SRC}/${FN_BASE}" "${DN_REPO_PKG}/${FN_BASE}"
            ;;
        svn)
            ${MYEXEC} cp -rp "${DN_REPO_SRC}/${FN_BASE}" "${DN_REPO_PKG}/${FN_BASE}"
            ;;
        wget|local)
            FNDOWN=$(echo "${DECLNXOUT_RENAME}" | awk -F? '{print $1}' | xargs basename)
            ${MYEXEC} ln -s "${DN_REPO_SRC}/${FNDOWN}" "${DN_REPO_PKG}/${FNDOWN}"
            ;;
        esac
    done
}

srcdir="${DN_REPO_PKG}"

mkdir -p "${DN_REPO_SRC}"
mkdir -p "${DN_REPO_PKG}"



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
