#!/usr/bin/env bash
###############################################################################
# BHATARA OS v2.0.1.2 - Display Branding & Wallpaper Installer
# Applies ONLY visual appearance (wallpaper + display text/version)
# Does NOT modify APT repositories, download URLs, or Ubuntu/Debian OS IDs.
###############################################################################

set -e

BHATARA_VERSION="2.0.1.2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WALLPAPER_LANDSCAPE="${REPO_DIR}/assets/bhatara-wallpaper.png"
WALLPAPER_PORTRAIT="${REPO_DIR}/assets/bhatara-wallpaper-portrait.png"

_c_magenta="\e[1;49;95m"
_c_green="\e[1;49;32m"
_c_blue="\e[1;49;94m"
_c_red="\e[1;49;91m"
RST="\e[0m"

info() { echo -e "${_c_blue}-> ${*}${RST}"; }
ok()   { echo -e "${_c_green}[OK] ${*}${RST}"; }
warn() { echo -e "${_c_red}[W] ${*}${RST}"; }

if [ ! -f "${WALLPAPER_LANDSCAPE}" ]; then
    warn "Wallpaper file not found: ${WALLPAPER_LANDSCAPE}"
    exit 1
fi

apply_to_rootfs() {
    local rootfs="$1"
    if [ ! -d "${rootfs}/etc" ]; then
        return 0
    fi

    info "Applying BHATARA OS v${BHATARA_VERSION} branding & wallpaper to: ${rootfs}"

    # 1. Install wallpaper assets into rootfs
    mkdir -p "${rootfs}/usr/share/backgrounds/bhatara"
    mkdir -p "${rootfs}/usr/share/backgrounds/xfce"
    cp -f "${WALLPAPER_LANDSCAPE}" "${rootfs}/usr/share/backgrounds/bhatara/bhatara-wallpaper.png"
    cp -f "${WALLPAPER_LANDSCAPE}" "${rootfs}/usr/share/backgrounds/bhatara-wallpaper.png"
    cp -f "${WALLPAPER_LANDSCAPE}" "${rootfs}/usr/share/backgrounds/xfce/bhatara-wallpaper.png"
    if [ -f "${WALLPAPER_PORTRAIT}" ]; then
        cp -f "${WALLPAPER_PORTRAIT}" "${rootfs}/usr/share/backgrounds/bhatara/bhatara-wallpaper-portrait.png"
    fi

    # Replace default fallback wallpapers (preserving originals as .orig once)
    for default_wp in \
        "${rootfs}/usr/share/backgrounds/warty-final-ubuntu.png" \
        "${rootfs}/usr/share/backgrounds/xfce/xfce-verticals.png" \
        "${rootfs}/usr/share/backgrounds/xfce/xfce-stripes.png"; do
        if [ -f "${default_wp}" ]; then
            [ ! -f "${default_wp}.orig" ] && cp -f "${default_wp}" "${default_wp}.orig"
            cp -f "${WALLPAPER_LANDSCAPE}" "${default_wp}"
        fi
    done

    # 2. Configure XFCE4 system-wide & user desktop wallpaper
    mkdir -p "${rootfs}/etc/xdg/xfce4/xfconf/xfce-perchannel-xml"
    cat > "${rootfs}/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitor0" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/bhatara-wallpaper.png"/>
        </property>
      </property>
      <property name="monitorscreen" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/bhatara-wallpaper.png"/>
        </property>
      </property>
      <property name="monitorVNC-0" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/bhatara-wallpaper.png"/>
        </property>
      </property>
    </property>
  </property>
</channel>
EOF

    # Apply XFCE4 config to root and all /home/* users
    for home_dir in "${rootfs}/root" "${rootfs}/home/"*; do
        if [ -d "${home_dir}" ]; then
            mkdir -p "${home_dir}/.config/xfce4/xfconf/xfce-perchannel-xml"
            cp -f "${rootfs}/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml" \
                  "${home_dir}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml"
        fi
    done

    # 3. Configure GNOME & MATE wallpaper defaults via gschema override
    if [ -d "${rootfs}/usr/share/glib-2.0/schemas" ]; then
        cat > "${rootfs}/usr/share/glib-2.0/schemas/99_bhatara-wallpaper.gschema.override" <<'EOF'
[org.gnome.desktop.background]
picture-uri='file:///usr/share/backgrounds/bhatara-wallpaper.png'
picture-uri-dark='file:///usr/share/backgrounds/bhatara-wallpaper.png'
picture-options='zoom'

[org.mate.background]
picture-filename='/usr/share/backgrounds/bhatara-wallpaper.png'
picture-options='zoom'
EOF
    fi

    # 4. Autostart helper to ensure wallpaper applies on any VNC/X11 monitor name
    mkdir -p "${rootfs}/usr/local/bin" "${rootfs}/etc/xdg/autostart"
    cat > "${rootfs}/usr/local/bin/bhatara-set-wallpaper" <<'EOF'
#!/usr/bin/env bash
WP="/usr/share/backgrounds/bhatara-wallpaper.png"
[ -f "$WP" ] || exit 0
if command -v xfconf-query >/dev/null 2>&1; then
    for prop in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep -E "last-image$|image-path$"); do
        xfconf-query -c xfce4-desktop -p "$prop" -s "$WP" 2>/dev/null || true
    done
fi
if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.background picture-uri "file://${WP}" 2>/dev/null || true
    gsettings set org.gnome.desktop.background picture-uri-dark "file://${WP}" 2>/dev/null || true
    gsettings set org.mate.background picture-filename "${WP}" 2>/dev/null || true
fi
EOF
    chmod +x "${rootfs}/usr/local/bin/bhatara-set-wallpaper"

    cat > "${rootfs}/etc/xdg/autostart/bhatara-wallpaper.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=BHATARA OS Wallpaper Setup
Comment=Applies BHATARA OS v2.0.1.2 desktop wallpaper
Exec=/usr/local/bin/bhatara-set-wallpaper
OnlyShowIn=XFCE;MATE;GNOME;
X-GNOME-Autostart-enabled=true
NoDisplay=true
EOF

    # 5. Update display-only OS text & version (preserves ID=ubuntu & VERSION_CODENAME for APT!)
    cat > "${rootfs}/etc/bhatara-release" <<EOF
BHATARA_NAME="BHATARA OS"
BHATARA_VERSION="${BHATARA_VERSION}"
BHATARA_CODENAME="BHATARA"
EOF

    cat > "${rootfs}/etc/issue" <<EOF
BHATARA OS ${BHATARA_VERSION} \n \l

EOF

    cat > "${rootfs}/etc/motd" <<EOF
================================================
  Welcome to BHATARA OS v${BHATARA_VERSION}
================================================
EOF

    for osrel in "${rootfs}/etc/os-release" "${rootfs}/usr/lib/os-release"; do
        if [ -f "${osrel}" ] && [ ! -L "${osrel}" ]; then
            [ ! -f "${osrel}.orig" ] && cp -f "${osrel}" "${osrel}.orig"
            sed -i \
                -e "s/^PRETTY_NAME=.*/PRETTY_NAME=\"BHATARA OS ${BHATARA_VERSION}\"/" \
                -e "s/^NAME=.*/NAME=\"BHATARA OS\"/" \
                "${osrel}"
        fi
    done

    ok "BHATARA OS v${BHATARA_VERSION} theme & wallpaper applied to ${rootfs}"
}

# Detect target rootfs directories (explicit argument, Termux proot-distro/udroid)
FOUND=0
if [ "${1:-}" = "--host" ] || [ "${1:-}" = "/" ]; then
    apply_to_rootfs "/" 2>/dev/null || true
    FOUND=1
elif [ -n "${1:-}" ] && [ -d "$1" ]; then
    apply_to_rootfs "$1"
    FOUND=1
else
    for base_dir in \
        "${PREFIX:-/data/data/com.termux/files/usr}/var/lib/udroid/installed-filesystems" \
        "${PREFIX:-/data/data/com.termux/files/usr}/var/lib/proot-distro/installed-rootfs" \
        "${HOME}/.udroid/installed-rootfs"; do
        if [ -d "${base_dir}" ]; then
            for dir in "${base_dir}"/*; do
                if [ -d "${dir}/etc" ]; then
                    apply_to_rootfs "${dir}"
                    FOUND=1
                fi
            done
        fi
    done
fi

if [ "${FOUND}" -eq 0 ]; then
    info "No installed rootfs detected yet. Wallpaper & theme assets are ready in: ${REPO_DIR}/assets/"
    info "After installing BHATARA OS via install.sh, run: bash scripts/apply-bhatara-theme.sh"
fi
