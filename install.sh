#!/bin/bash

rm -f $0
export DEBIAN_FRONTEND=noninteractive
apt update -y
apt install curl -y
apt install wget -y
apt install jq -y

NC='\033[0m'
rbg='\033[41;37m'
r='\033[1;91m'
g='\033[1;92m'
y='\033[1;93m'
u='\033[0;35m'
c='\033[0;96m'
w='\033[1;97m'

if [ "${EUID}" -ne 0 ]; then
echo "${r}You need to run this script as root${NC}"
sleep 2
exit 0
fi

if [[ ! -f /root/.isp ]]; then
curl -sS ipinfo.io/org?token=7a814b6263b02c > /root/.isp
fi
if [[ ! -f /root/.city ]]; then
curl -sS ipinfo.io/city?token=7a814b6263b02c > /root/.city
fi
if [[ ! -f /root/.myip ]]; then
curl -sS ipv4.icanhazip.com > /root/.myip
fi

export IP=$(cat /root/.myip);
export ISP=$(cat /root/.isp);
export CITY=$(cat /root/.city);
source /etc/os-release

function up_lane() {
echo -e "${c}┌──────────────────────────────────────────┐${NC}"
}
function down_lane() {
echo -e "${c}└──────────────────────────────────────────┘${NC}"
}

apt update
data_server=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
date_list=$(date +"%Y-%m-%d" -d "$data_server")
url_izin="https://raw.githubusercontent.com/ianlunatix/ip_access/main/ip"
client=$(curl -sS $url_izin | grep $IP | awk '{print $2}')
exp=$(curl -sS $url_izin | grep $IP | awk '{print $3}')
today=`date -d "0 days" +"%Y-%m-%d"`
time=$(printf '%(%H:%M:%S)T')
date=$(date +'%d-%m-%Y')
d1=$(date -d "$exp" +%s)
d2=$(date -d "$today" +%s)
certifacate=$(((d1 - d2) / 86400))
checking_sc() {
  useexp=$(curl -s $url_izin | grep $IP | awk '{print $3}')
  if [[ $date_list < $useexp ]]; then
    echo -ne
  else
    clear
    echo -e "\033[96m────────────────────────────────────────────\033[0m"
    echo -e "\033[41;37m             Expired Autoscript             \033[0m"
    echo -e "\033[96m────────────────────────────────────────────\033[0m"
    echo -e ""
    echo -e " \033[31mIP Address access is not allowed\033[0m"
    echo -e ""
    echo -e "   1  IP ADRESS || 1 BULAN   :  5.000  Rp"
    echo -e "   5  IP ADRESS || 1 BULAN   :  30.000 Rp"
    echo -e "   10 IP ADRESS || 1 BULAN   :  50.000 Rp"
    echo -e "   UNLIMITED IP || 1 TAHUN   : 150.000 Rp"
    echo -e "   OPEN SOURCE  || HAK MILIK : 250.000 Rp"     
    echo -e ""
    echo -e "\033[96m────────────────────────────────────────────\033[0m"    
    echo -e " \033[34mWhatsapp  : +6283197765857 \033[0m"
    echo -e "\033[96m────────────────────────────────────────────\033[0m"
    exit 0
  fi
}
checking_sc

if [[ "$( uname -m | awk '{print $1}' )" == "x86_64" ]]; then
    echo -ne
else
    echo -e "${r} Your Architecture Is Not Supported ( ${y}$( uname -m )${NC} )"
    exit 1
fi

if [[ ${ID} == "ubuntu" || ${ID} == "debian" ]]; then
    echo -ne
else
    echo -e " ${r}This Script only Support for OS"
    echo -e ""
    echo -e " - ${y}Ubuntu 20.04${NC}"
    echo -e " - ${y}Ubuntu 21.04${NC}"
    echo -e " - ${y}Ubuntu 22.04${NC}"
    echo -e " - ${y}Ubuntu 23.04${NC}"
    echo -e " - ${y}Ubuntu 24.04${NC}"
    echo ""
    echo -e " - ${y}Debian 10${NC}"
    echo -e " - ${y}Debian 11${NC}"
    echo -e " - ${y}Debian 12${NC}"
    
    exit 0
fi

if [[ ${VERSION_ID} == "10" || ${VERSION_ID} == "11" || ${VERSION_ID} == "12" || ${VERSION_ID} == "20.04" || ${VERSION_ID} == "21.04" || ${VERSION_ID} == "22.04" || ${VERSION_ID} == "23.04" || ${VERSION_ID} == "24.04" ]]; then
    echo -ne
else
    echo -e " ${r}This Script only Support for OS"
    echo -e ""
    echo -e " - ${y}Ubuntu 20.04${NC}"
    echo -e " - ${y}Ubuntu 21.04${NC}"
    echo -e " - ${y}Ubuntu 22.04${NC}"
    echo -e " - ${y}Ubuntu 23.04${NC}"
    echo -e " - ${y}Ubuntu 24.04${NC}"
    echo ""
    echo -e " - ${y}Debian 10${NC}"
    echo -e " - ${y}Debian 11${NC}"
    echo -e " - ${y}Debian 12${NC}"
    
    exit 0
fi

if [ "$(systemd-detect-virt)" == "openvz" ]; then
echo "OpenVZ is not supported"
exit 1
fi

function generate_random_subdomain() {

    sub=$(head /dev/urandom | tr -dc a-z0-9 | head -c 8)
}

function pointing() {
    apt update -y
    apt install jq curl -y

    DOMAIN=ltexec.xyz
    generate_random_subdomain
    SUBDOMAIN="${sub}.${DOMAIN}"
    WILDCARD="*.${SUBDOMAIN}"

    CF_KEY="88a8619c3dec8a0c9a14cf353684036108844"
    CF_ID="newvpnlunatix293@gmail.com"
    IP=$(curl -s ipv4.icanhazip.com)

    echo ""
    echo -e "🔧 Proses pointing domain: ${SUBDOMAIN} (dan wildcard)..."
    sleep 1

    ZONE=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}&status=active" \
        -H "X-Auth-Email: ${CF_ID}" \
        -H "X-Auth-Key: ${CF_KEY}" \
        -H "Content-Type: application/json" | jq -r .result[0].id)

    # --------------------------
    # Fungsi untuk buat/replace record A
    create_or_update_dns() {
        local RECORD_NAME=$1

        RECORD=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${RECORD_NAME}" \
            -H "X-Auth-Email: ${CF_ID}" \
            -H "X-Auth-Key: ${CF_KEY}" \
            -H "Content-Type: application/json" | jq -r .result[0].id)

        if [[ "${#RECORD}" -le 10 ]]; then
            # Create baru
            curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
                -H "X-Auth-Email: ${CF_ID}" \
                -H "X-Auth-Key: ${CF_KEY}" \
                -H "Content-Type: application/json" \
                --data '{"type":"A","name":"'${RECORD_NAME}'","content":"'${IP}'","ttl":1,"proxied":false}' > /dev/null
        else
            # Update existing
            curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD}" \
                -H "X-Auth-Email: ${CF_ID}" \
                -H "X-Auth-Key: ${CF_KEY}" \
                -H "Content-Type: application/json" \
                --data '{"type":"A","name":"'${RECORD_NAME}'","content":"'${IP}'","ttl":1,"proxied":false}' > /dev/null
        fi
    }

    # Point domain utama & wildcard
    create_or_update_dns "${SUBDOMAIN}"
    create_or_update_dns "${WILDCARD}"

    # Simpan domain untuk kebutuhan XRAY
    echo "${SUBDOMAIN}" > /etc/xray/domain

    echo ""
    echo -e "✅ Subdomain aktif: \e[92m${SUBDOMAIN}\e[0m"
    echo -e "✅ Wildcard aktif: \e[92m${WILDCARD}\e[0m"
    
}

function SETUPDIR_DOMENS() {
local main_dirs=(
        "/etc/xray" "/var/lib/LT" "/etc/lunatic" "/etc/limit"
        "/etc/vmess" "/etc/vless" "/etc/trojan" "/etc/ssh"
    )
    
    local lunatic_subdirs=("vmess" "vless" "trojan" "ssh" "bot")
    local lunatic_types=("usage" "ip" "detail")

    local protocols=("vmess" "vless" "trojan" "ssh")

    for dir in "${main_dirs[@]}"; do
        mkdir -p "$dir"
    done

    for service in "${lunatic_subdirs[@]}"; do
        for type in "${lunatic_types[@]}"; do
            mkdir -p "/etc/lunatic/$service/$type"
        done
    done

    for protocol in "${protocols[@]}"; do
        mkdir -p "/etc/limit/$protocol"
    done

    local databases=(
        "/etc/lunatic/vmess/.vmess.db"
        "/etc/lunatic/vless/.vless.db"
        "/etc/lunatic/trojan/.trojan.db"
        "/etc/lunatic/ssh/.ssh.db"
        "/etc/lunatic/bot/.bot.db"
    )

    for db in "${databases[@]}"; do
        touch "$db"
        echo "& plugin Account" >> "$db"
    done

    touch /etc/.{ssh,vmess,vless,trojan}.db
    echo "IP=" > /var/lib/LT/ipvps.conf

    
############### POINTING IP VPS TO DOMAIN IN THE CLOUDFLARE #################
    pointing
}


############ SETUP DOMAIN & CREATE DIRECTORY #############
SETUPDIR_DOMENS




############ INSTALL TOOLS.SH #############
function TOOLS_DEPENDENS() {
cd
wget https://raw.githubusercontent.com/ianlunatix/dhipe/main/tools.sh &> /dev/null
chmod +x tools.sh 
yes "" | bash tools.sh
sudo apt install at -y >/dev/null 2>&1

wget -q -O /etc/port.txt "https://raw.githubusercontent.com/ianlunatix/dhipe/main/port.txt"

clear
start=$(date +%s)
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
apt install git curl -y >/dev/null 2>&1
apt install python -y >/dev/null 2>&1
}

function ALL_SETUPLERS(){
animation_loading() {
    CMD[0]="$1"
    CMD[1]="$2"
    
    (
        # Hapus file fim jika ada
        [[ -e $HOME/fim ]] && rm -f $HOME/fim
        
        # Jalankan perintah di background dan sembunyikan output
        ${CMD[0]} -y >/dev/null 2>&1
        ${CMD[1]} -y >/dev/null 2>&1
        
        # Buat file fim untuk menandakan selesai
        touch $HOME/fim
    ) >/dev/null 2>&1 &

    tput civis # Sembunyikan kursor
    echo -ne "  \033[0;33mProcessed Install \033[1;37m- \033[0;33m["
    
    while true; do
        for ((i = 0; i < 18; i++)); do
            echo -ne "\033[0;32m#"
            sleep 0.1
        done
        
        # Jika file fim ada, hapus dan keluar dari loop
        if [[ -e $HOME/fim ]]; then
            rm -f $HOME/fim
            break
        fi
        
        echo -e "\033[0;33m]"
        sleep 1
        tput cuu1 # Kembali ke baris sebelumnya
        tput dl1   # Hapus baris sebelumnya
        echo -ne "  \033[0;33mProcessed Install \033[1;37m- \033[0;33m["
    done
    
    echo -e "\033[0;33m]\033[1;37m -\033[1;32m Succes !\033[1;37m"
    tput cnorm # Tampilkan kursor kembali
}


SETUP_SSH_VPN() {
wget https://raw.githubusercontent.com/ianlunatix/dhipe/main/ssh_module/ssh-vpn.sh && chmod +x ssh-vpn.sh && ./ssh-vpn.sh

# installer gotop
gotop_latest="$(curl -s https://api.github.com/repos/xxxserxxx/gotop/releases | grep tag_name | sed -E 's/.*"v(.*)".*/\1/' | head -n 1)"
gotop_link="https://github.com/xxxserxxx/gotop/releases/download/v$gotop_latest/gotop_v"$gotop_latest"_linux_amd64.deb"
curl -sL "$gotop_link" -o /tmp/gotop.deb
dpkg -i /tmp/gotop.deb

clear
} 

SETUP_XRAY_ENGINE() {
wget https://raw.githubusercontent.com/ianlunatix/dhipe/main/xray_engine/ins-xray.sh && chmod +x ins-xray.sh && ./ins-xray.sh
clear
}

SETUP_WEBSOCKET() {
wget https://raw.githubusercontent.com/ianlunatix/dhipe/main/websocket_engine/install-ws.sh && chmod +x install-ws.sh && ./install-ws.sh
clear
}

SETUP_RC_BACKUP() {
apt install rclone
printf "q\n" | rclone config
wget -O /root/.config/rclone/rclone.conf "https://github.com/ianlunatix/dhipe/raw/main/rclone.conf"
git clone  https://github.com/zhets/wondershaper.git
cd wondershaper
make install
cd
rm -rf wondershaper
    
rm -f /root/set-br.sh
rm -f /root/limit.sh
}

SETUP_OHPSERV() {
wget https://raw.githubusercontent.com/ianlunatix/dhipe/main/websocket_engine/ohp.sh && chmod +x ohp.sh && yes "" | ./ohp.shh
clear
}

MANAGER_MENU() {
wget https://raw.githubusercontent.com/ianlunatix/dhipe/main/HandlerSentry/install_menu.sh && chmod +x install_menu.sh && yes "" | ./install_menu.sh
clear
}

LIMIT_HANDLER() {
wget https://raw.githubusercontent.com/ianlunatix/dhipe/main/limit_handler/install.sh && chmod +x install.sh && yes "" | ./install.sh
clear
}

SETUP_CUSTOM_UDP() {
wget https://raw.githubusercontent.com/ianlunatix/dhipe/main/UDP.sh && chmod +x UDP.sh && yes "" | ./UDP.sh
clear
}


if [[ $(cat /etc/os-release | grep -w ID | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/ID//g') == "ubuntu" ]]; then
echo -e "${g}Setup nginx For OS Is $(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')${NC}"
UBUNTU_INSTALLER
elif [[ $(cat /etc/os-release | grep -w ID | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/ID//g') == "debian" ]]; then
echo -e "${g}Setup nginx For OS Is $(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')${NC}"
DEBIAN_INSTALLER
else
echo -e " Your OS Is Not Supported ( ${YELLOW}$(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')${FONT} )"
fi
}


function DEBIAN_INSTALLER(){
up_lane
echo -e "${c}│      ${g}PROCESS INSTALLED SSH & OPENVPN${NC}     ${c}│${NC}"
down_lane
animation_loading 'SETUP_SSH_VPN'

up_lane
echo -e "${c}│           ${g}PROCESS INSTALLED XRAY${NC}         ${c}│${NC}"
down_lane
animation_loading 'SETUP_XRAY_ENGINE'

up_lane
echo -e "${c}│       ${g}PROCESS INSTALLED WEBSOCKET SSH${NC}    ${c}│${NC}"
down_lane
animation_loading 'SETUP_WEBSOCKET'

up_lane
echo -e "${c}│       ${g}PROCESS INSTALLED BACKUP MENU${NC}${c}      │${NC}"
down_lane
animation_loading 'SETUP_RC_BACKUP'

up_lane
echo -e "${c}│           ${g}PROCESS INSTALLED OHP${NC}${c}          │${NC}"
down_lane
animation_loading 'SETUP_OHPSERV'

up_lane
echo -e "${c}│           ${g}DOWNLOAD EXTRA MENU${NC}${c}            │${NC}"
down_lane
animation_loading 'MANAGER_MENU'

up_lane
echo -e "${c}│         ${g}DOWNLOAD KILL QUOTA LIMIT${NC}${c}            │${NC}"
down_lane
animation_loading 'LIMIT_HANDLER'

up_lane
echo -e "${c}│           ${g}DOWNLOAD UDP CUSTOM${NC}${c}            │${NC}"
down_lane
animation_loading 'SETUP_CUSTOM_UDP'

}

function UBUNTU_INSTALLER(){
up_lane
echo -e "${c}│      ${g}PROCESS INSTALLED SSH & OPENVPN${NC}     ${c}│${NC}"
down_lane
animation_loading 'SETUP_SSH_VPN'

up_lane
echo -e "${c}│           ${g}PROCESS INSTALLED XRAY${NC}         ${c}│${NC}"
down_lane
animation_loading 'SETUP_XRAY_ENGINE'

up_lane
echo -e "${c}│       ${g}PROCESS INSTALLED WEBSOCKET SSH${NC}    ${c}│${NC}"
down_lane
SETUP_WEBSOCKET

up_lane
echo -e "${c}│       ${g}PROCESS INSTALLED BACKUP MENU${NC}${c}      │${NC}"
down_lane
animation_loading 'SETUP_RC_BACKUP'

up_lane
echo -e "${c}│           ${g}PROCESS INSTALLED OHP${NC}${c}          │${NC}"
down_lane
animation_loading 'SETUP_OHPSERV'

up_lane
echo -e "${c}│           ${g}DOWNLOAD EXTRA MENU${NC}${c}            │${NC}"
down_lane
animation_loading 'MANAGER_MENU'

up_lane
echo -e "${c}│         ${g}DOWNLOAD KILL QUOTA LIMIT${NC}${c}            │${NC}"
down_lane
animation_loading 'LIMIT_HANDLER'

up_lane
echo -e "${c}│           ${g}DOWNLOAD UDP CUSTOM${NC}${c}            │${NC}"
down_lane
animation_loading 'SETUP_CUSTOM_UDP'
}

# Tentukan nilai baru yang diinginkan untuk fs.file-max
NEW_FILE_MAX=65535  # Ubah sesuai kebutuhan Anda

# Nilai tambahan untuk konfigurasi netfilter
NF_CONNTRACK_MAX="net.netfilter.nf_conntrack_max=262144"
NF_CONNTRACK_TIMEOUT="net.netfilter.nf_conntrack_tcp_timeout_time_wait=30"

# File yang akan diedit
SYSCTL_CONF="/etc/sysctl.conf"

# Ambil nilai fs.file-max saat ini
CURRENT_FILE_MAX=$(grep "^fs.file-max" "$SYSCTL_CONF" | awk '{print $3}' 2>/dev/null)

# Cek apakah nilai fs.file-max sudah sesuai
if [ "$CURRENT_FILE_MAX" != "$NEW_FILE_MAX" ]; then
    # Cek apakah fs.file-max sudah ada di file
    if grep -q "^fs.file-max" "$SYSCTL_CONF"; then
        # Jika ada, ubah nilainya
        sed -i "s/^fs.file-max.*/fs.file-max = $NEW_FILE_MAX/" "$SYSCTL_CONF" >/dev/null 2>&1
    else
        # Jika tidak ada, tambahkan baris baru
        echo "fs.file-max = $NEW_FILE_MAX" >> "$SYSCTL_CONF" 2>/dev/null
    fi
fi

# Cek apakah net.netfilter.nf_conntrack_max sudah ada
if ! grep -q "^net.netfilter.nf_conntrack_max" "$SYSCTL_CONF"; then
    echo "$NF_CONNTRACK_MAX" >> "$SYSCTL_CONF" 2>/dev/null
fi

# Cek apakah net.netfilter.nf_conntrack_tcp_timeout_time_wait sudah ada
if ! grep -q "^net.netfilter.nf_conntrack_tcp_timeout_time_wait" "$SYSCTL_CONF"; then
    echo "$NF_CONNTRACK_TIMEOUT" >> "$SYSCTL_CONF" 2>/dev/null
fi

# Terapkan perubahan
sysctl -p >/dev/null 2>&1

TOOLS_DEPENDENS
ALL_SETUPLERS

    cat >/etc/cron.d/xp_all <<-END
		SHELL=/bin/sh
		PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
		2 0 * * * root /usr/bin/xp
	END
    cat >/etc/cron.d/logclean <<-END
		SHELL=/bin/sh
		PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
		*/59 * * * * root /usr/bin/logclean
	END
	    cat >/etc/cron.d/daily_reboot <<-END
		SHELL=/bin/sh
		PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
		0 5 * * * /sbin/reboot
	END
			   
cat> /root/.profile << END
if [ "$BASH" ]; then
if [ -f ~/.bashrc ]; then
. ~/.bashrc
fi
fi
mesg n || true
clear
menu
END
chmod 644 /root/.profile
if [ -f "/root/log-install.txt" ]; then
rm /root/log-install.txt > /dev/null 2>&1
fi
if [ -f "/etc/afak.conf" ]; then
rm /etc/afak.conf > /dev/null 2>&1
fi
history -c
serverV=$( curl -sS https://raw.githubusercontent.com/ianlunatix/dhipe/main/versi  )
echo $serverV > /root/.versi
echo "00" > /home/daily_reboot
aureb=$(cat /home/daily_reboot)
b=11
if [ $aureb -gt $b ]
then
gg="PM"
else
gg="AM"
fi
cd

curl -sS ifconfig.me > /etc/myipvps
curl -s ipinfo.io/city?token=75082b4831f909 >> /etc/xray/city
curl -s ipinfo.io/org?token=75082b4831f909  | cut -d " " -f 2-10 >> /etc/xray/isp

rm -f /root/*.sh
rm -f /root/*.txt

#secs_to_human "$(($(date +%s) - ${start}))" | tee -a log-install.txt


CHATID="7428226275"
KEY="7382456251:AAFFC-8A6VsotlfAQj6MXe4Mff-7MNX5yRs"
URL="https://api.telegram.org/bot$KEY/sendMessage"
TEXT="
<code>=========================</code>
<b>   🧱 AUTOSCRIPT PREMIUM 🧱 </b>
<b>        Notifications       </b>
<code>=========================</code>
<b>Client  :</b> <code>$client</code>
<b>ISP     :</b> <code>$ISP</code>
<b>Country :</b> <code>$CITY</code>
<b>DATE    :</b> <code>$date</code>
<b>Time    :</b> <code>$time</code>
<b>Expired :</b> <code>$exp</code>
<code>=========================</code>
<b>        LUNATIC TUNNELING     </b>
<code>=========================</code>
<i>Automatic Notifications From</i>
<i>LUNATIC</i>

"'&reply_markup={"inline_keyboard":[[{"text":" ʙᴜʏ ꜱᴄʀɪᴘᴛ ","url":"https://wa.me/6283197765857"}]]}' 
    curl -s --max-time 10 -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null

cd
rm ~/.bash_history
rm -f openvpn
rm -f key.pem
rm -f cert.pem


## fix Dropbear ##
chmod 755 /usr/sbin/dropbear
systemctl restart dropbear

## 
sleep 2
echo  ""
cd
clear
echo -e "${c}┌────────────────────────────────────────────┐${NC}"
echo -e "${c}│  ${g}INSTALL SCRIPT SELESAI..${NC}                  ${c}│${NC}"
echo -e "${c}└────────────────────────────────────────────┘${NC}"
echo  ""
sleep 4
echo -e "[ ${yell}WARNING${NC} ] Do you want to reboot now ? (y/n)? "
read answer
if [ "$answer" == "${answer#[Yy]}" ] ;then
exit 0
else
reboot
fi
