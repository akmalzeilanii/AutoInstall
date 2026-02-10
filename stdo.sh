#!/bin/bash
set -e
clear

### WARNA ###
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

### KEY & EXPIRE ###
SECRET_KEY="vrlywn"
EXPIRY_DATE="2027-03-31"

current_date=$(date +%Y-%m-%d)
if [[ "$current_date" > "$EXPIRY_DATE" ]]; then
  echo -e "${RED}Script expired.${NC}"
  exit 1
fi

read -sp "Enter secret key: " input_key
echo
[[ "$input_key" != "$SECRET_KEY" ]] && echo "Invalid key" && exit 1

### INFO ###
echo -e "${GREEN}Windows Auto Installer - DigitalOcean${NC}"
echo -e "${YELLOW}Only Windows Server 2019 DO (Stable)${NC}"
sleep 2

### PASSWORD ###
read -sp "Set Administrator password (enter for default): " PASSWORD
echo
PASSWORD=${PASSWORD:-"Nixpoin.com123!"}

### NETWORK ###
IP4=$(curl -4 -s icanhazip.com)
GW=$(ip route | awk '/default/ {print $3}')

### net.bat ###
cat >/tmp/net.bat <<EOF
@echo off
net user Administrator $PASSWORD
netsh interface ip set address "Ethernet" static $IP4 255.255.240.0 $GW
netsh interface ip add dns "Ethernet" 1.1.1.1
netsh interface ip add dns "Ethernet" 8.8.4.4 index=2
del "%~f0"
EOF

### DOWNLOAD ###
IMG_URL="https://sourceforge.net/projects/nixpoin/files/windows2019DO.gz/download"
IMG="windows2019DO.gz"

echo -e "${CYAN}Downloading Windows image...${NC}"
wget -O "$IMG" "$IMG_URL"

### VALIDASI ###
SIZE=$(stat -c%s "$IMG")
if [ "$SIZE" -lt 3000000000 ]; then
  echo -e "${RED}File too small, download failed.${NC}"
  exit 1
fi

echo -e "${CYAN}Checking gzip integrity...${NC}"
gunzip -t "$IMG"

### WRITE DISK ###
echo -e "${YELLOW}Writing image to disk... DO NOT INTERRUPT${NC}"
gunzip -c "$IMG" | dd of=/dev/vda bs=8M status=progress

sync || true

### FINISH ###
echo -e "${GREEN}Installation finished.${NC}"
echo -e "${RED}Server will power off in 5 seconds.${NC}"
sleep 5

poweroff || reboot -f
