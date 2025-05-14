FROM --platform=linux/amd64 ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update -y && apt install --no-install-recommends -y xfce4 xfce4-goodies tigervnc-standalone-server novnc websockify sudo xterm init systemd snapd vim net-tools curl wget git tzdata
RUN apt update -y && apt install -y dbus-x11 x11-utils x11-xserver-utils x11-apps
RUN apt install software-properties-common -y

RUN apt update -y && apt install -y ca-certificates gnupg lsb-release
RUN wget -qO- https://deb.opera.com/archive.key | gpg --dearmor > /usr/share/keyrings/opera-browser.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/opera-browser.gpg] https://deb.opera.com/opera-stable/ stable non-free" | tee /etc/apt/sources.list.d/opera-archive.list
RUN apt update -y && apt install -y opera-stable

RUN apt update -y && apt install -y xubuntu-icon-theme
RUN touch /root/.Xauthority
EXPOSE 5901
EXPOSE 6080
CMD bash -c "vncserver -localhost no -SecurityTypes None -geometry 1024x768 --I-KNOW-THIS-IS-INSECURE && openssl req -new -subj "/C=JP" -x509 -days 365 -nodes -out self.pem -keyout self.pem && websockify -D --web=/usr/share/novnc/ --cert=self.pem 6080 localhost:5901 && tail -f /dev/null"