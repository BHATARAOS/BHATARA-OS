#!/usr/bin/env bash
ACTION="${1:-xfce4}"
GEOMETRY="${2:-1280x720}"
DISPLAY_NUM="${BHATARA_DISPLAY:-1}"
PORT="$((5900 + DISPLAY_NUM))"

_c_green="\e[1;49;32m"
_c_blue="\e[1;49;94m"
_c_yellow="\e[1;49;33m"
_c_red="\e[1;49;91m"
RST="\e[0m"

is_termux() {
    [ -n "${TERMUX_VERSION:-}" ] || [ -d "/data/data/com.termux/files/usr" ]
}

stop_all() {
    echo -e "${_c_yellow}-> Menghentikan seluruh sesi VNC BHATARA OS...${RST}"
    pkill -9 -f Xtigervnc 2>/dev/null || true
    rm -rf /tmp/.X*-lock /tmp/.X11-unix/X* "${HOME}/.vnc/"*.pid 2>/dev/null || true
    if is_termux; then
        command -v termux-wake-unlock >/dev/null 2>&1 && termux-wake-unlock || true
    fi
    echo -e "${_c_green}[OK] Server BHATARA OS berhasil dimatikan.${RST}"
}

if [ "$ACTION" = "stop" ] || [ "$ACTION" = "kill" ]; then
    stop_all
    exit 0
fi

case "$ACTION" in
    xfce4|mate|gnome) VARIANT="$ACTION" ;;
    *)
        echo -e "${_c_red}[E] Varian tidak dikenal: ${ACTION}${RST}"
        echo "Penggunaan: $(basename "$0") [xfce4|mate|gnome|stop] [1280x720]"
        exit 1
        ;;
esac

build_xstartup_cmd() {
    local v="$1"
    local u="$2"
    case "$v" in
        xfce4)
            printf '%s' "mkdir -p ~/.vnc && printf '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexport XDG_RUNTIME_DIR=/tmp/runtime-${u}\nmkdir -p \$XDG_RUNTIME_DIR && chmod 700 \$XDG_RUNTIME_DIR\nexec dbus-launch --exit-with-session startxfce4\n' > ~/.vnc/xstartup && chmod +x ~/.vnc/xstartup"
            ;;
        mate)
            printf '%s' "mkdir -p ~/.vnc && printf '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexport XDG_RUNTIME_DIR=/tmp/runtime-${u}\nmkdir -p \$XDG_RUNTIME_DIR && chmod 700 \$XDG_RUNTIME_DIR\nexec dbus-launch --exit-with-session mate-session\n' > ~/.vnc/xstartup && chmod +x ~/.vnc/xstartup"
            ;;
        gnome)
            printf '%s' "mkdir -p ~/.vnc && printf '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexport XDG_RUNTIME_DIR=/tmp/runtime-${u}\nmkdir -p \$XDG_RUNTIME_DIR && chmod 700 \$XDG_RUNTIME_DIR\nexport XDG_CURRENT_DESKTOP=GNOME-Flashback:GNOME\nexport XDG_MENU_PREFIX=gnome-\ncommand -v feh >/dev/null 2>&1 && [ -f /usr/share/backgrounds/bhatara-wallpaper.png ] && feh --bg-scale /usr/share/backgrounds/bhatara-wallpaper.png &\nmetacity --replace &\ngnome-flashback &\nexec dbus-run-session -- gnome-panel\n' > ~/.vnc/xstartup && chmod +x ~/.vnc/xstartup"
            ;;
    esac
}

if is_termux; then
    command -v udroid >/dev/null 2>&1 || { echo -e "${_c_red}[E] 'udroid' belum terpasang.${RST}"; exit 1; }
    command -v termux-wake-lock >/dev/null 2>&1 && termux-wake-lock || true
    echo -e "${_c_blue}-> Menyalakan BHATARA OS (jammy:${VARIANT}) di Termux...${RST}"
    INNER_SETUP="$(build_xstartup_cmd "$VARIANT" "root")"
    INNER_CMD="${INNER_SETUP} && pkill -9 -f Xtigervnc 2>/dev/null ; rm -rf /tmp/.X*-lock /tmp/.X11-unix/X* /root/.vnc/*.pid ; vncserver :${DISPLAY_NUM} -localhost yes -SecurityTypes None -geometry ${GEOMETRY} -depth 24 && echo '[OK] BHATARA OS (${VARIANT}) aktif di 127.0.0.1:${PORT}'"
    udroid login "jammy:${VARIANT}" -- bash -c "${INNER_CMD} ; exec bash"
else
    command -v vncserver >/dev/null 2>&1 || { echo -e "${_c_red}[E] 'vncserver' belum terpasang.${RST}"; exit 1; }
    echo -e "${_c_blue}-> Menyalakan BHATARA OS (${VARIANT}) pada display :${DISPLAY_NUM} (${GEOMETRY})...${RST}"
    eval "$(build_xstartup_cmd "$VARIANT" "${USER:-user}")"
    pkill -9 -f Xtigervnc 2>/dev/null || true
    rm -rf /tmp/.X*-lock /tmp/.X11-unix/X* "${HOME}/.vnc/"*.pid 2>/dev/null || true
    vncserver ":${DISPLAY_NUM}" -localhost yes -SecurityTypes None -geometry "${GEOMETRY}" -depth 24
    echo -e "${_c_green}[OK] BHATARA OS (${VARIANT}) berjalan di 127.0.0.1:${PORT}${RST}"
fi
