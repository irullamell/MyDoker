#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${GREEN}========================================${NC}\n"
}

if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Script ini harus dijalankan dengan sudo!${NC}"
    exit 1
fi

START_TIME=$(date +%s)
BEFORE_DISK=$(df / | tail -1 | awk '{print $4}')
BEFORE_MEMORY=$(free -m | grep Mem | awk '{print $4}')

echo -e "${CYAN}Menganalisis sistem...${NC}"
TOTAL_SIZE_BEFORE=$(df -h / | tail -1 | awk '{print $3}')

print_header "PEMBERSIHAN SISTEM DIMULAI"

apt-get clean
apt-get autoclean
apt-get autoremove --purge -y
dpkg --configure -a
apt-get install -f
apt-get purge ~c -y

if command -v snap &> /dev/null; then
    rm -rf /var/lib/snapd/cache/*
    snap list --all | while read snapname ver rev trk pub notes; do
        if [[ $notes = *disabled* ]]; then
            snap remove "$snapname" --revision="$rev"
        fi
    done
fi

find /var/log -type f -name "*.gz" -delete
find /var/log -type f -name "*.old" -delete
find /var/log -type f -name "*.1" -delete
find /var/log -type f -name "*.2" -delete
find /var/log -type f -name "*.3" -delete
find /var/log -type f -name "*.4" -delete
find /var/log -type f -name "*.5" -delete
find /var/log -type f -name "*.[0-9]" -delete
find /var/log -type f -size +100M -delete

journalctl --vacuum-time=1d
journalctl --vacuum-size=10M

for log in /var/log/*.log /var/log/**/*.log /var/log/syslog; do
    if [ -f "$log" ]; then
        echo "" > "$log"
    fi
done

find /home -type d -name ".cache" -exec rm -rf {} + 2>/dev/null
find /home -type d -name ".thumbnails" -exec rm -rf {} + 2>/dev/null
find /home -type d -name "Cache" -exec rm -rf {} + 2>/dev/null
find /home -type d -name "cache" -exec rm -rf {} + 2>/dev/null
find /home -type d -name "CachedData" -exec rm -rf {} + 2>/dev/null
find /home -type d -name "Code Cache" -exec rm -rf {} + 2>/dev/null

rm -rf /tmp/*
rm -rf /var/tmp/*
rm -rf /var/cache/*
rm -rf /var/backups/*
rm -rf /var/crash/*
rm -rf /var/lib/systemd/coredump/*

find /home -name "*.tmp" -delete
find /home -name "*.temp" -delete
find /home -name "*.swp" -delete
find /home -name "*.swo" -delete
find /home -name "*~" -delete
find /home -name ".~*" -delete
find /home -name "Thumbs.db" -delete
find /home -name ".DS_Store" -delete

for user_home in /home/*; do
    rm -rf "$user_home/.local/share/Trash/files/"*
    rm -rf "$user_home/.local/share/Trash/info/"*
    rm -rf "$user_home/.local/share/baloo/"*
    rm -rf "$user_home/.xsession-errors"*
    rm -rf "$user_home/.local/share/akonadi/"*
    rm -rf "$user_home/.cache/google-chrome/"*
    rm -rf "$user_home/.cache/chromium/"*
    rm -rf "$user_home/.cache/mozilla/"*
    rm -rf "$user_home/.cache/thunderbird/"*
    rm -rf "$user_home/.cache/opera/"*
    rm -rf "$user_home/.cache/vivaldi/"*
    rm -rf "$user_home/.cache/BraveSoftware/"*
    rm -rf "$user_home/.cache/Microsoft/"*
    rm -rf "$user_home/.cache/microsoft-edge/"*
    rm -rf "$user_home/.cache/yay/"*
    rm -rf "$user_home/.cache/pip/"*
    rm -rf "$user_home/.cache/go-build/"*
    rm -rf "$user_home/.npm/_logs/"*
    rm -rf "$user_home/.npm/_cacache/"*
    rm -rf "$user_home/.cache/JetBrains/"*
    rm -rf "$user_home/.cache/wine/"*
    rm -rf "$user_home/.cache/winetricks/"*
    rm -rf "$user_home/.cache/mesa_shader_cache/"*
    rm -rf "$user_home/.cache/fontconfig/"*
    rm -rf "$user_home/.cache/spotify/"*
    rm -rf "$user_home/.cache/discord/"*
    rm -rf "$user_home/.cache/slack/"*
    rm -rf "$user_home/.cache/zoom/"*
    rm -rf "$user_home/.cache/teams/"*
    rm -rf "$user_home/.cache/vscode-cpptools/"*
    rm -rf "$user_home/.cache/electron/"*
    rm -rf "$user_home/.cache/node/"*
    rm -rf "$user_home/.cache/yarn/"*
    rm -rf "$user_home/.cache/pnpm/"*
    rm -rf "$user_home/.config/Code/CachedData/"*
    rm -rf "$user_home/.config/Code/Cache/"*
    rm -rf "$user_home/.config/Code/CachedExtensions/"*
    rm -rf "$user_home/.config/VSCodium/CachedData/"*
    rm -rf "$user_home/.config/VSCodium/Cache/"*
done

rm -rf /home/*/.wget-hsts
rm -rf /home/*/.bash_history
rm -rf /home/*/.python_history
rm -rf /home/*/.mysql_history
rm -rf /home/*/.lesshst
rm -rf /home/*/.viminfo
rm -rf /home/*/.nano_history
rm -rf /home/*/.sqlite_history
rm -rf /home/*/.psql_history
rm -rf /home/*/.node_repl_history

rm -rf /root/.wget-hsts
rm -rf /root/.bash_history
rm -rf /root/.python_history
rm -rf /root/.mysql_history
rm -rf /root/.lesshst
rm -rf /root/.viminfo
rm -rf /root/.nano_history
rm -rf /root/.cache/*

CURRENT_KERNEL=$(uname -r)
OLD_KERNELS=$(dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | head -n -5)

if [ -n "$OLD_KERNELS" ]; then
    apt-get remove --purge $OLD_KERNELS -y
fi

if command -v flatpak &> /dev/null; then
    flatpak uninstall --unused -y
    rm -rf /var/tmp/flatpak-cache-*
fi

if command -v pip &> /dev/null; then
    pip cache purge
fi

if command -v pip3 &> /dev/null; then
    pip3 cache purge
fi

if command -v npm &> /dev/null; then
    npm cache clean --force
fi

if command -v yarn &> /dev/null; then
    yarn cache clean
fi

if command -v composer &> /dev/null; then
    composer clear-cache
fi

if command -v docker &> /dev/null; then
    docker system prune -a -f
    docker volume prune -f
fi

dpkg -l | grep ^rc | awk '{print $2}' | xargs dpkg --purge 2>/dev/null

deborphan | xargs apt-get -y remove --purge 2>/dev/null

find /var -type f -name "*.deb" -delete
find /home -type f -name "*.deb" -delete

updatedb 2>/dev/null

echo 3 > /proc/sys/vm/drop_caches

if [ $(swapon -s | wc -l) -gt 1 ]; then
    swapoff -a
    swapon -a
fi

AFTER_DISK=$(df / | tail -1 | awk '{print $4}')
AFTER_MEMORY=$(free -m | grep Mem | awk '{print $4}')
TOTAL_SIZE_AFTER=$(df -h / | tail -1 | awk '{print $3}')

DISK_FREED=$((AFTER_DISK - BEFORE_DISK))
MEMORY_FREED=$((AFTER_MEMORY - BEFORE_MEMORY))

DISK_FREED_GB=$(echo "scale=2; $DISK_FREED/1048576" | bc)
MEMORY_FREED_MB=$MEMORY_FREED

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

print_header "HASIL PEMBERSIHAN"
echo -e "${BLUE}████████████████████████████████████████${NC}"
echo -e "${CYAN}         RINGKASAN PEMBERSIHAN          ${NC}"
echo -e "${BLUE}████████████████████████████████████████${NC}"
echo -e ""
echo -e "${YELLOW}Waktu eksekusi:${NC} ${GREEN}$DURATION detik${NC}"
echo -e ""
echo -e "${YELLOW}RUANG DISK:${NC}"
echo -e "  ${CYAN}Sebelum:${NC} $TOTAL_SIZE_BEFORE digunakan"
echo -e "  ${CYAN}Sesudah:${NC} $TOTAL_SIZE_AFTER digunakan"
echo -e "  ${GREEN}Dibebaskan:${NC} ${GREEN}$DISK_FREED_GB GB${NC}"
echo -e ""
echo -e "${YELLOW}MEMORI RAM:${NC}"
echo -e "  ${CYAN}Sebelum:${NC} $BEFORE_MEMORY MB tersedia"
echo -e "  ${CYAN}Sesudah:${NC} $AFTER_MEMORY MB tersedia"
echo -e "  ${GREEN}Dibebaskan:${NC} ${GREEN}$MEMORY_FREED_MB MB${NC}"
echo -e ""
echo -e "${BLUE}████████████████████████████████████████${NC}"
echo -e "${GREEN}     PEMBERSIHAN SELESAI SEMPURNA!      ${NC}"
echo -e "${BLUE}████████████████████████████████████████${NC}"
echo -e ""
echo -e "${YELLOW}Sistem Anda sekarang:${NC}"
echo -e "  ${GREEN}✓${NC} Lebih cepat"
echo -e "  ${GREEN}✓${NC} Lebih responsif"
echo -e "  ${GREEN}✓${NC} Lebih banyak ruang kosong"
echo -e "  ${GREEN}✓${NC} Cache dan sampah terhapus total"
echo -e ""
df -h
echo -e ""
free -h
