#!/bin/bash

clear
# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Define the secret key (should be kept secret)
SECRET_KEY="vrlywn"
EXPIRY_DATE="2027-03-31"  # Set the expiration date (YYYY-MM-DD)

# Get current date
current_date=$(date +%Y-%m-%d)

# Check if the current date is before the expiration date
if [[ "$current_date" > "$EXPIRY_DATE" ]]; then
    echo -e "${RED}The script has expired. Please contact the administrator.${NC}"
    exit 1
fi

# Calculate the time remaining until expiration
expiry_seconds=$(date -d "$EXPIRY_DATE" +%s)
current_seconds=$(date +%s)
remaining_seconds=$((expiry_seconds - current_seconds))

# Convert remaining seconds to days
remaining_days=$((remaining_seconds / 86400))

# Ask for the secret key before proceeding
echo -e "${MAGENTA} ┌────────────────────────────────────────────────────────────────────────────────────────┐ ${NC}"
echo -e "${MAGENTA} │${NC}             ${CYAN}Please enter your secret key to unlock the script${NC}            ${MAGENTA}│ ${NC}"
echo -e "${MAGENTA} └────────────────────────────────────────────────────────────────────────────────────────┘ ${NC}"

read -sp "Enter the key: " input_key
echo

# Check if the key matches
if [ "$input_key" != "$SECRET_KEY" ]; then
    echo -e "${RED}Invalid key. Access denied.${NC}"
    exit 1
fi

# If the key is correct, proceed with showing the server information
echo -e "${MAGENTA} ┌────────────────────────────────────────────────────────────────────────────────────────┐ ${NC}"
echo -e "${MAGENTA} │${NC}              ${YELLOW}Server Information${NC}                ${MAGENTA}│ ${NC}"
echo -e "${MAGENTA} ├────────────────────────────────────────────────────────────────────────────────────────┤ ${NC}"
echo -e "${MAGENTA} │${NC} ${CYAN}Version       : 1.0 WD${NC}                            ${MAGENTA}│ ${NC}"
echo -e "${MAGENTA} │${NC} ${CYAN}Creator       : Warkop Digital${NC}                   ${MAGENTA}│ ${NC}"
echo -e "${MAGENTA} │${NC} ${CYAN}Client Name   : Windows RDP${NC}                      ${MAGENTA}│ ${NC}"
echo -e "${MAGENTA} │${NC} ${CYAN}Provider      : DigitalOcean${NC}                     ${MAGENTA}│ ${NC}"
echo -e "${MAGENTA} │${NC} ${CYAN}Expiry In     : ${remaining_days} days remaining${NC}               ${MAGENTA}│ ${NC}"
echo -e "${MAGENTA} └────────────────────────────────────────────────────────────────────────────────────────┘ ${NC}"

# Select Windows Version
echo -e "${RED} ┌────────────────────────────────────────────────┐ ${NC}"
echo -e "${RED} │${NC}         ${CYAN}Select Your Windows Version${NC}           ${RED}│ ${NC}"
echo -e "${RED} ├────────────────────────────────────────────────┤ ${NC}"
echo -e "${RED} │${NC} ${CYAN}1) Windows Server 2012${NC}                             ${RED}│ ${NC}"
echo -e "${RED} │${NC} ${CYAN}2) Windows Server 2016${NC}                             ${RED}│ ${NC}"
echo -e "${RED} │${NC} ${CYAN}3) Windows Server 2019${NC}                             ${RED}│ ${NC}"
echo -e "${RED} │${NC} ${CYAN}4) Windows Server 2022${NC}                             ${RED}│ ${NC}"
echo -e "${RED} │${NC} ${CYAN}5) Windows Server 10${NC}                              ${RED}│ ${NC}"
echo -e "${RED} │${NC} ${CYAN}6) Windows Server 11${NC}                              ${RED}│ ${NC}"
echo -e "${RED} └────────────────────────────────────────────────┘ ${NC}"

# Get user input for Windows version
read -p "Pilih (1-6): " pilihan

# URLs for the different Windows versions
case $pilihan in
    1)
        PILIHOS="https://sourceforge.net/projects/nixpoin/files/windows2012.gz"
        echo -e "${CYAN}Memulai instalasi Windows 2012...${NC}"
        ;;
    2)
        PILIHOS="https://sourceforge.net/projects/nixpoin/files/windows2016.gz"
        echo -e "${CYAN}Memulai instalasi Windows 2016...${NC}"
        ;;
    3)
        PILIHOS="https://sourceforge.net/projects/nixpoin/files/windows2019DO.gz"
        echo -e "${CYAN}Memulai instalasi Windows 2019...${NC}"
        ;;
    4)
        PILIHOS="https://sourceforge.net/projects/nixpoin/files/windows2022.gz"
        echo -e "${CYAN}Memulai instalasi Windows 2022...${NC}"
        ;;
    5)
        PILIHOS="https://sourceforge.net/projects/nixpoin/files/windows10.gz"
        echo -e "${CYAN}Memulai instalasi Windows 10...${NC}"
        ;;
    6)
        PILIHOS="https://sourceforge.net/projects/nixpoin/files/windows11.gz"
        echo -e "${CYAN}Memulai instalasi Windows 11...${NC}"
        ;;
    *)
        echo -e "${RED}Pilihan tidak valid!${NC}"
        exit 1
        ;;
esac

# Ask for password after selecting the Windows version
echo -e "${CYAN}Apakah Anda ingin mengatur kata sandi untuk akun Administrator?${NC}"
echo -e "${CYAN}1) Ya, saya ingin mengatur kata sandi saya sendiri${NC}"
echo -e "${CYAN}2) Tidak, gunakan kata sandi default${NC}"
read -p "Pilih (1-2): " set_password

if [ "$set_password" -eq 1 ]; then
    # Prompt for the password if user selects option 1
    read -sp "Masukkan kata sandi untuk akun Administrator: " PASSWORD
    echo
else
    # Set a default password if user selects option 2
    PASSWORD="Nixpoin.com123!"
    echo -e "${CYAN}Menggunakan kata sandi default: $PASSWORD${NC}"
fi

# Mengambil IP dan Gateway
IP4=$(curl -4 -s icanhazip.com)
GW=$(ip route | awk '/default/ { print $3 }')

# Membuat net.bat untuk settingan IP dan DNS otomatis
cat >/tmp/net.bat<<EOF
@ECHO OFF
cd.>%windir%\GetAdmin
if exist %windir%\GetAdmin (del /f /q "%windir%\GetAdmin") else (
echo CreateObject^("Shell.Application"^).ShellExecute "%~s0", "%*", "", "runas", 1 >> "%temp%\Admin.vbs"
"%temp%\Admin.vbs"
del /f /q "%temp%\Admin.vbs"
exit /b 2)
net user Administrator $PASSWORD

netsh -c interface ip set address name="Ethernet" source=static address=$IP4 mask=255.255.240.0 gateway=$GW
netsh -c interface ip add dnsservers name="Ethernet" address=1.1.1.1 index=1 validate=no
netsh -c interface ip add dnsservers name="Ethernet" address=8.8.4.4 index=2 validate=no

cd /d "%ProgramData%/Microsoft/Windows/Start Menu/Programs/Startup"
del /f /q net.bat
exit
EOF

# Download dan install image OS
echo "Mendownload file $PILIHOS..."
wget --no-check-certificate -O- $PILIHOS | gunzip | dd of=/dev/vda bs=3M status=progress

# Mount dan copy file setup
mount.ntfs-3g /dev/vda2 /mnt
cd "/mnt/ProgramData/Microsoft/Windows/Start Menu/Programs/"
cd Start* || cd start*; \
wget https://nixpoin.com/ChromeSetup.exe
cp -f /tmp/net.bat net.bat

# Shutdown
echo -e "${RED}Your server will turn off in 3 seconds...${RESET}"
sleep 3
poweroff
