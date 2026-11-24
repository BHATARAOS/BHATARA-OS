#!/usr/bin/env bash

####################################################
# BHATARA OS Installer Script v2.0.1.2
# Based on udroid installer (mad installer)
# Copyright (c) 2021 @RandomCoderOrg <hello.1x1.sai@gmail.com>

version="2.0.1.2"
version_code_name="BHATARA-2.0.1.2"
installer_authors="BHATARA OS / saicharankandukuri"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# COLORS
_c_magneta="\e[1;49;95m"
_c_magneta_line="\e[4;49;95m"
_c_green="\e[1;49;32m"
_c_red="\e[1;49;91m"
_c_blue="\e[1;49;94m"
RST="\e[0m"

trap 'echo -e "either CTRC+C or HUP INT TERM signals caught\nexiting.."; exit 1' HUP INT TERM

## current best distro
CUR_BEST_DISTRO="jammy:xfce4"
FSMGR_REPO="https://github.com/RandomCoderOrg/fs-manager-udroid.git"
FSMGR_BRANCH="main"
install_count="$(curl -s https://udroid-download-counter-api.vercel.app/count)"

die()    { echo -e "${_c_red}[E] ${*}${RST}";if [ -n "$DISABLE_EXIT" ];then exit 1; fi;:;}
warn()   { echo -e "${_c_red}[W] ${*}${RST}";:;}
shout()  { echo -e "${_c_blue}[-] ${*}${RST}";:;}
lshout() { echo -e "${_c_blue}-> ${*}${RST}";:;}
msg()    { echo -e "${*} \e[0m" >&2;:;}
banner_msg() { echo -e "\e[1;49;97m ${*} \e[0m" >&2;:;}

function logo() {
    # check if logo could fit in terminal with its current tty resolution
    tty_width=$(stty size 2>/dev/null | cut -d ' ' -f 2)
    tty_width=${tty_width:-0}

    if ((tty_width >= 56 )); then
        banner_msg "████████████████████████████████████████████████████████"
        echo
        banner_msg "██████╗░██╗░░██╗░█████╗░████████╗░█████╗░██████╗░░█████╗░"
        banner_msg "██╔══██╗██║░░██║██╔══██╗╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗"
        banner_msg "██████╦╝███████║███████║░░░██║░░░███████║██████╔╝███████║"
        banner_msg "██╔══██╗██╔══██║██╔══██║░░░██║░░░██╔══██║██╔══██╗██╔══██║"
        banner_msg "██████╦╝██║░░██║██║░░██║░░░██║░░░██║░░██║██║░░██║██║░░██║"
        banner_msg "╚═════╝░╚═╝░░╚═╝╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░╚═╝"
        echo
        banner_msg "████████████ BHATARA OS v${version} █████████████████████"
        lshout "${install_count} installs so far \e[0m...."
    else
        # Just in case the logo is too big for your terminal ( Happens to new termux users )
        lshout "${_c_magneta}BHATARA OS INSTALLER v$version\e[0m...."
        lshout "${_c_magneta}${install_count} installs so far"
        lshout "\e[90m© BHATARA OS"
    fi
    sleep 1
}

logo

# Check device os & CPU architecture
# just to make sure its not armv7l 
# (armv7l is not supported cause of 64bit cpu and 32bit os)
lshout "Checking cpu architecture.."
if [ "$(uname -m)" = "armv7l" ]; then
    die "Sorry, armv7l is not supported.."
fi
msg "CPU architecture is OK."

# Check for required packages
# git:          for cloning BHATARA OS sources
# jq:           for parsing distro data json files
# wget:         for downloading udroid filesystems
# proot:        for changing root to filesystems without root ( main element )
# pv:           for showing progress while downloading/extracting filesystems
# pulseaudio:   for audio support
lshout "Checking for required packages.."
DEPENDS="git jq wget proot pv pulseaudio openssl"
TOINSTALL=""

for DEPEND in $DEPENDS; do
    if [ -z "$(command -v "$DEPEND")" ]; then
        TOINSTALL="$TOINSTALL $DEPEND"
    fi
done
if [ -n "$TOINSTALL" ]; then
    lshout "Installing required (missing) packages.."
    pkg install -y $TOINSTALL || {
        die "Failed to install required packages. \"pkg install -y $TOINSTALL\""
    }
else
    lshout "All required packages are already installed."
fi

# clone fs-manager-udroid
# a proot-distro fork for udroid with some extra features

git clone -b $FSMGR_BRANCH $FSMGR_REPO || {
    die "Failed to clone fs-manager-udroid"
}
cd fs-manager-udroid || {
    die "Failed to cd into fs-manager-udroid"
}

# trigger install.sh
# this will install fs-manager-udroid

bash install.sh || {
    die "Failed to install fs-manager-udroid"
}


## finally install a good stable distro
lshout "Installing BHATARA OS ($CUR_BEST_DISTRO) v$version in 3 seconds.."
lshout "press q or CTRL+C to stop here.."
read -r -n 1 -t 3 noi
if [[ $noi == "q" ]]; then
    echo -e "\n\n"
    echo "q read: stopping $CUR_BEST_DISTRO installation.."
    echo "you can still install with: udroid l $CUR_BEST_DISTRO"
    echo
else
    udroid install $CUR_BEST_DISTRO || {
        die "Failed to install $CUR_BEST_DISTRO"
    }

    ## Apply BHATARA OS v2.0.1.2 wallpaper and display branding
    if [ -f "${SCRIPT_DIR}/scripts/apply-bhatara-theme.sh" ]; then
        lshout "Applying BHATARA OS v$version wallpaper and display theme.."
        bash "${SCRIPT_DIR}/scripts/apply-bhatara-theme.sh" || warn "Theme setup skipped; run bash scripts/apply-bhatara-theme.sh manually."
    fi

    ## show some info
    lshout "BHATARA OS v$version installation completed successfully."
    lshout
    lshout "To login $CUR_BEST_DISTRO, run \"${_c_green}udroid login $CUR_BEST_DISTRO\""
    lshout "use ${_c_magneta}vncserver :1${RST} to start vnc server"
    lshout "default password for everything is ${_c_magneta}secret${RST}"
    lshout "Show us some love by starring our repo on github and donating"
    msg
    msg "BHATARA OS source: ${_c_magneta_line}https://github.com/RandomCoderOrg/ubuntu-on-android${RST}"
    msg "support us:        ${_c_magneta_line}https://github.com/sponsors/RandomCoderOrg${RST}"
    msg "Join our discord:  ${_c_magneta_line}https://discord.gg/AGqQCHuE6S${RST}"
    msg
fi
