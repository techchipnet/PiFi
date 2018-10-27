#!/bin/sh
#This script create for auto setup Raspberry Pi 3 WiFi Router
# Author - Anil Parashar
# www.techchip.net
# www.youtube.com/techchipnet
clear
/bin/cat <<'Techchip'
 _______        _      _____ _     _       
|__   __|      | |    / ____| |   (_)      
   | | ___  ___| |__ | |    | |__  _ _ __  
   | |/ _ \/ __| '_ \| |    | '_ \| | '_ \ 
   | |  __/ (__| | | | |____| | | | | |_) |
   |_|\___|\___|_| |_|\_____|_| |_|_| .__/ 
                                    | |    
    Your True Tech Navigator        |_|.net    
www.techchip.net | youtube.com/techchipnet	
Techchip
if [ $? != 0 ] 
then
  echo "This program must be run as root. run again as root"
  exit 1
fi
read -r -p "This script make change your system's network configurations files, I am not responsible for any damage, Do you agree with it? [y/N] " check

case "$check" in
[nN][oO]|[nN])
echo "Thank you!! have a nice day ;) don't forget subscribe TechChip Youtube Channel"
exit 1
;;
*)
echo ""
echo "First you need to be update your system"
read -p "Do you want update your system (Y/N)?" ans

if [ $ans = "y" ] || [ $ans = "Y" ]
then
  echo "Updating package index.."
  sudo apt-get update -y
  echo "Updating old packages.."
  sudo apt-get upgrade -y
fi
echo ""
echo "Downloading and installing necessary packages.."
sudo apt install hostapd bridge-utils -y
echo ""
echo "Backing up existing config files..."
if [ -f /etc/hostapd/hostapd.conf ]
	then
		sudo mv /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf.old
fi
if [ -f /etc/network/interfaces ]
	then
		sudo mv /etc/network/interfaces /etc/network/interfaces.old
fi
if [ -f /etc/default/hostapd ]
	then
		sudo mv /etc/default/hostapd /etc/default/hostapd.old
fi
echo ""
echo "configuration start..."
echo ""
read -p "Enter your PIFI SSID: " apname
read -p "Enter password (password must be >= 8 char): " appass
if [ ! $apname ]
then
apname="PiFi"
echo ""
echo "SSID can't be blank now your SSID is :" $apname
fi
if [ ${#appass} -lt 8 ]
then
appass="techchipnet"
echo ""
echo "Your password length is short now your WiFi password is : " $appass
fi
sudo cat > hostapd.conf <<EOF
# WiFi access point configuration
bridge=br0
interface=wlan0
ssid=$apname
hw_mode=g
channel=6
wmm_enabled=1
macaddr_acl=0
auth_algs=1
wpa=2
wpa_passphrase=$appass
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
wpa_pairwise=TKIP

EOF

sudo cat > interfaces << EOF
# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
allow-hotplug eth0
iface eth0 inet manual

# The WiFi network interface
auto wlan0
allow-hotplug wlan0
iface wlan0 inet manual
wireless-power off

# Bridge network interface
auto br0
iface br0 inet dhcp
bridge_ports eth0 wlan0
bridge_fd 0
bridge_stp off
EOF
sudo cat > hostapd << EOF
RUN_DAEMON=yes
DAEMON_CONF="/etc/hostapd/hostapd.conf"
EOF
sudo mv interfaces /etc/network/interfaces
sudo mv hostapd.conf /etc/hostapd/hostapd.conf
sudo mv hostapd /etc/default/hostapd
sudo chown root:root /etc/network/interfaces
sudo chown root:root /etc/hostapd/hostapd.conf
sudo chown root:root /etc/default/hostapd
echo ""
echo "Configuration is completed"
echo "Reboot your system for start PiFi(Raspberry Pi WiFi Router)"
echo ""
echo "Don't forget to subscribe TechChip Youtube channel"
echo ""
read -p "Press [Enter] key to reboot or terminate here, press (ctrl+c).." chk
sudo reboot
;;
esac
