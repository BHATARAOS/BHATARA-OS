FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive USER=root HOME=/root DISPLAY=:1 VNC_GEOMETRY=1280x720
RUN apt-get update && apt-get install -y --no-install-recommends xfce4 xfce4-goodies tigervnc-standalone-server dbus-x11 feh novnc websockify sudo curl wget git ca-certificates && apt-get clean && rm -rf /var/lib/apt/lists/*
WORKDIR /opt/bhatara-os
COPY assets/ /opt/bhatara-os/assets/
COPY scripts/ /opt/bhatara-os/scripts/
RUN chmod +x /opt/bhatara-os/scripts/*.sh && bash /opt/bhatara-os/scripts/apply-bhatara-theme.sh / && mkdir -p /root/.vnc && printf '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexport XDG_RUNTIME_DIR=/tmp/runtime-root\nmkdir -p $XDG_RUNTIME_DIR && chmod 700 $XDG_RUNTIME_DIR\nexec dbus-launch --exit-with-session startxfce4\n' > /root/.vnc/xstartup && chmod +x /root/.vnc/xstartup
EXPOSE 5901 6080
CMD bash -c "rm -rf /tmp/.X*-lock /tmp/.X11-unix/X* /root/.vnc/*.pid && vncserver :1 -localhost no -SecurityTypes None -geometry ${VNC_GEOMETRY} -depth 24 && websockify --web=/usr/share/novnc/ 6080 localhost:5901"
