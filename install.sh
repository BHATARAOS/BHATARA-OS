#!/usr/bin/env bash
set -o pipefail

version="2.0.1.2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

_c_magenta="\e[1;49;95m"
_c_green="\e[1;49;32m"
_c_red="\e[1;49;91m"
_c_blue="\e[1;49;94m"
_c_yellow="\e[1;49;33m"
RST="\e[0m"

trap 'echo -e "\n${_c_red}[!] Interrupted. Exiting...${RST}"; exit 1' HUP INT TERM

VARIANT=""
THEME_ONLY=0
DEFAULT_GEOMETRY="1280x720"
FSMGR_REPO="https://github.com/RandomCoderOrg/fs-manager-udroid.git"
FSMGR_BRANCH="main"

die()    { echo -e "${_c_red}[E] ${*}${RST}" >&2; exit 1; }
warn()   { echo -e "${_c_yellow}[W] ${*}${RST}" >&2; }
ok()     { echo -e "${_c_green}[OK] ${*}${RST}"; }
lshout() { echo -e "${_c_blue}-> ${*}${RST}"; }
msg()    { echo -e "${*}${RST}"; }

for arg in "$@"; do
    case "$arg" in
        --variant=*) VARIANT="${arg#*=}" ;;
        --geometry=*) DEFAULT_GEOMETRY="${arg#*=}" ;;
        --theme-only) THEME_ONLY=1 ;;
        -h|--help)
            echo "Usage: bash install.sh [--variant=xfce4|mate|gnome] [--geometry=1280x720] [--theme-only]"
            exit 0
            ;;
    esac
done

detect_platform() {
    local uname_s
    uname_s="$(uname -s 2>/dev/null || echo Unknown)"
    if [ -n "${TERMUX_VERSION:-}" ] || [ -d "/data/data/com.termux/files/usr" ]; then
        echo "termux"
    elif [[ "$uname_s" == MINGW* || "$uname_s" == MSYS* \vert{}\vert{} "$uname_s" == CYGWIN* ]]; then
        echo "windows_gitbash"
    elif [ "$uname_s" = "Darwin" ]; then
        echo "macos"
    elif [ "$uname_s" = "Linux" ]; then
        if grep -qiE "microsoft|wsl" /proc/version 2>/dev/null; then
            echo "wsl"
        else
            echo "linux_desktop"
        fi
    else
        echo "unknown"
    fi
}

choose_variant() {
    if [ -n "$VARIANT" ]; then
        case "$VARIANT" in
            xfce4|mate|gnome) return 0 ;;
            *) VARIANT="xfce4"; return 0 ;;
        esac
    fi
    echo ""
    msg "${_c_magenta}Pilih Varian Desktop BHATARA OS:${RST}"
    msg "  1) ${_c_green}XFCE4${RST} (Default - Ringan & cepat)"
    msg "  2) ${_c_blue}MATE${RST}  (Klasik & menengah)"
    msg "  3) ${_c_yellow}GNOME${RST} (Mode GNOME Flashback - Stabil di VNC/Proot)"
    echo -ne "${_c_blue}-> Pilihan [1-3] (otomatis 1 dalam 8 detik):${RST}"
    local choice=""
    read -r -t 8 choice || true
    echo ""
    case "$choice" in
        2) VARIANT="mate" ;;
        3) VARIANT="gnome" ;;
        *) VARIANT="xfce4" ;;
    esac
    ok "Varian terpilih: ${VARIANT}"
}

write_xstartup_for_variant() {
    local target_home="$1"
    local variant="$2"
    local user_tag="${3:-root}"
    mkdir -p "${target_home}/.vnc"
    case "$variant" in
        xfce4)
            printf '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexport XDG_RUNTIME_DIR=/tmp/runtime-%s\nmkdir -p $XDG_RUNTIME_DIR && chmod 700 $XDG_RUNTIME_DIR\nexec dbus-launch --exit-with-session startxfce4\n' "$user_tag" > "${target_home}/.vnc/xstartup"
            ;;
        mate)
            printf '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexport XDG_RUNTIME_DIR=/tmp/runtime-%s\nmkdir -p $XDG_RUNTIME_DIR && chmod 700 $XDG_RUNTIME_DIR\nexec dbus-launch --exit-with-session mate-session\n' "$user_tag" > "${target_home}/.vnc/xstartup"
            ;;
        gnome)
            printf '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexport XDG_RUNTIME_DIR=/tmp/runtime-%s\nmkdir -p $XDG_RUNTIME_DIR && chmod 700 $XDG_RUNTIME_DIR\nexport XDG_CURRENT_DESKTOP=GNOME-Flashback:GNOME\nexport XDG_MENU_PREFIX=gnome-\ncommand -v feh >/dev/null 2>&1 && [ -f /usr/share/backgrounds/bhatara-wallpaper.png ] && feh --bg-scale /usr/share/backgrounds/bhatara-wallpaper.png &\nmetacity --replace &\ngnome-flashback &\nexec dbus-run-session -- gnome-panel\n' "$user_tag" > "${target_home}/.vnc/xstartup"
            ;;
    esac
    chmod +x "${target_home}/.vnc/xstartup"
}

install_termux() {
    lshout "Platform terdeteksi: ${_c_green}Android (Termux)${RST}"
    [ "$(uname -m)" = "armv7l" ] && die "Arsitektur 32-bit armv7l tidak didukung."
    command -v termux-wake-lock >/dev/null 2>&1 && termux-wake-lock || true

    choose_variant
    local target_distro="jammy:${VARIANT}"

    local DEPENDS="git jq wget proot pv pulseaudio openssl"
    local TOINSTALL=""
    for DEPEND in $DEPENDS; do
        command -v "$DEPEND" >/dev/null 2>&1 || TOINSTALL="$TOINSTALL $DEPEND"
    done
    if [ -n "$TOINSTALL" ]; then
        pkg update -y || true
        pkg install -y $TOINSTALL || die "Gagal menginstal paket: $TOINSTALL"
    fi

    if ! command -v udroid >/dev/null 2>&1; then
        local fsmgr_dir="${HOME}/fs-manager-udroid"
        rm -rf "$fsmgr_dir"
        git clone -b "$FSMGR_BRANCH" "$FSMGR_REPO" "$fsmgr_dir" || die "Gagal mengkloning fs-manager-udroid."
        (cd "$fsmgr_dir" && bash install.sh) || die "Gagal memasang fs-manager-udroid."
    fi

    udroid install "$target_distro" || die "Gagal menginstal ${target_distro}."
    [ -f "${SCRIPT_DIR}/scripts/apply-bhatara-theme.sh" ] && bash "${SCRIPT_DIR}/scripts/apply-bhatara-theme.sh" || true

    for base_dir in \
        "${PREFIX:-/data/data/com.termux/files/usr}/var/lib/udroid/installed-filesystems" \
        "${PREFIX:-/data/data/com.termux/files/usr}/var/lib/proot-distro/installed-rootfs" \
        "${HOME}/.udroid/installed-rootfs"; do
        if [ -d "${base_dir}" ]; then
            for dir in "${base_dir}"/*; do
                [ -d "${dir}/root" ] && write_xstartup_for_variant "${dir}/root" "$VARIANT" "root"
            done
        fi
    done

    if [ -f "${SCRIPT_DIR}/scripts/start-bhatara.sh" ] && [ -n "${PREFIX:-}" ]; then
        cp -f "${SCRIPT_DIR}/scripts/start-bhatara.sh" "${PREFIX}/bin/bhatara"
        chmod +x "${PREFIX}/bin/bhatara"
    fi
    ok "BHATARA OS (${target_distro}) selesai dipasang! Jalankan: bhatara ${VARIANT}"
}

install_linux_or_wsl() {
    local plat="$1"
    lshout "Platform terdeteksi: ${_c_green}${plat}${RST}"
    local SUDO=""
    [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1 && SUDO="sudo"

    if [ "$THEME_ONLY" -eq 0 ] && [ "$plat" = "linux_desktop" ]; then
        msg "${_c_magenta}Pilih Mode Instalasi di Linux Desktop:${RST}"
        msg "  1) ${_c_green}Full Desktop + VNC Server${RST}"
        msg "  2) ${_c_blue}Tema & Wallpaper Saja${RST}"
        echo -ne "${_c_blue}-> Pilihan [1-2] (otomatis 1 dalam 8 detik): ${RST}"
        local mode_choice=""
        read -r -t 8 mode_choice || true
        echo ""
        [ "$mode_choice" = "2" ] && THEME_ONLY=1
    fi

    if [ "$THEME_ONLY" -eq 1 ]; then
        bash "${SCRIPT_DIR}/scripts/apply-bhatara-theme.sh" --host || die "Gagal menerapkan tema."
        ok "Tema & wallpaper BHATARA OS diterapkan!"
        return 0
    fi

    choose_variant

    if command -v apt-get >/dev/null 2>&1; then
        $SUDO apt-get update -y || die "apt-get update gagal."
        local base_pkgs="git curl wget dbus-x11 tigervnc-standalone-server feh"
        local de_pkgs=""
        case "$VARIANT" in
            xfce4) de_pkgs="xfce4 xfce4-goodies" ;;
            mate)  de_pkgs="mate-desktop-environment-core mate-terminal" ;;
            gnome) de_pkgs="gnome-panel metacity gnome-menus gnome-flashback gnome-terminal nautilus" ;;
        esac
        DEBIAN_FRONTEND=noninteractive $SUDO apt-get install -y $base_pkgs $de_pkgs || die "Gagal menginstal paket desktop."
    elif command -v dnf >/dev/null 2>&1; then
        local base_pkgs="git curl wget dbus-x11 tigervnc-server feh"
        case "$VARIANT" in
            xfce4) $SUDO dnf install -y $base_pkgs @xfce-desktop-environment ;;
            mate)  $SUDO dnf install -y $base_pkgs @mate-desktop-environment ;;
            gnome) $SUDO dnf install -y $base_pkgs gnome-panel metacity gnome-terminal nautilus ;;
        esac
    elif command -v pacman >/dev/null 2>&1; then
        local base_pkgs="git curl wget tigervnc feh"
        case "$VARIANT" in
            xfce4) $SUDO pacman -S --noconfirm --needed $base_pkgs xfce4 xfce4-goodies ;;
            mate)  $SUDO pacman -S --noconfirm --needed $base_pkgs mate mate-extra ;;
            gnome) $SUDO pacman -S --noconfirm --needed $base_pkgs gnome-flashback gnome-panel metacity gnome-terminal nautilus ;;
        esac
    else
        die "Manajer paket tidak didukung otomatis. Gunakan Docker: docker compose up -d"
    fi

    [ -f "${SCRIPT_DIR}/scripts/apply-bhatara-theme.sh" ] && bash "${SCRIPT_DIR}/scripts/apply-bhatara-theme.sh" --host || true

    local cur_user="${SUDO_USER:-$USER}"
    local cur_home
    cur_home="$(eval echo "~${cur_user}")"
    write_xstartup_for_variant "$cur_home" "$VARIANT" "$cur_user"

    if [ -f "${SCRIPT_DIR}/scripts/start-bhatara.sh" ]; then
        $SUDO cp -f "${SCRIPT_DIR}/scripts/start-bhatara.sh" /usr/local/bin/bhatara
        $SUDO chmod +x /usr/local/bin/bhatara
    fi
    ok "Instalasi selesai! Nyalakan VNC: bhatara ${VARIANT} ${DEFAULT_GEOMETRY} | Hubungkan ke 127.0.0.1:5901"
}

install_macos() {
    lshout "Platform terdeteksi: ${_c_green}macOS${RST}"
    command -v docker >/dev/null 2>&1 || die "Pasang Docker Desktop / OrbStack terlebih dahulu, lalu jalankan ulang bash install.sh"
    cd "$SCRIPT_DIR" || exit 1
    docker compose up -d --build || docker-compose up -d --build || die "Gagal menjalankan Docker."
    ok "BHATARA OS aktif di browser: http://localhost:6080 (VNC: localhost:5901)"
}

install_windows_gitbash() {
    if [ -f "${SCRIPT_DIR}/install-windows.bat" ]; then
        cmd.exe /c "$(cygpath -w "${SCRIPT_DIR}/install-windows.bat" 2>/dev/null || echo install-windows.bat)"
    else
        die "Jalankan install-windows.bat dari Windows Explorer."
    fi
}

lshout "${_c_magenta}BHATARA OS UNIVERSAL INSTALLER v${version}${RST}"
PLATFORM="$(detect_platform)"
case "$PLATFORM" in
    termux)            install_termux ;;
    wsl|linux_desktop) install_linux_or_wsl "$PLATFORM" ;;
    macos)             install_macos ;;
    windows_gitbash)   install_windows_gitbash ;;
    *)                 die "Platform tidak dikenali. Gunakan: docker compose up -d --build" ;;
esac
