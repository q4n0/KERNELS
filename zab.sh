apt update && ap upgrade -y  && apt -y install git wget curl wget && apt autoremove && curl -fsSL https://pkgs.zabbly.com/key.asc | gpg --show-keys --fingerprint && mkdir -p /etc/apt/keyrings/
curl -fsSL https://pkgs.zabbly.com/key.asc -o /etc/apt/keyrings/zabbly.asc && sh -c 'cat <<EOF > /etc/apt/sources.list.d/zabbly-kernel-stable.sources 
Enabled: yes
Types: deb
URIs: https://pkgs.zabbly.com/kernel/stable
Suites: bookworm
Components: main
Architectures: amd64
Signed-By: /etc/apt/keyrings/zabbly.asc

EOF'

apt update && apt -y upgrade && apt-get -y install linux-zabbly && apt upgrade && apt autoremove -y && update-grub && reboot
