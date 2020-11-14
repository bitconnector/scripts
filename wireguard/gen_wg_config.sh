#!/bin/sh

#install qrencode
#uci get wireguard_server.servers
#https://openwrt.org/docs/guide-user/services/vpn/wireguard/server

config_file="./config.conf"

if [ ! -f "$config_file" ]; then
	echo "file doesnt exists"
	default_config=$(
		cat <<EOF
#you have to fill out this config yourself
server_pub=
server_port=
server_ip=
client_ip=192.168.7.2 #next free ip on wg interface
route_ips="192.168.7.0/24, 192.168.8.0/24" #LAN (.7 for wg and .8 for lan)
#route_ips="0.0.0.0/0, ::/0" #VPN (just everything)
dns=192.168.8.1 #DNS server in the other network
EOF
	)
	echo "$default_config" >"$config_file"
fi

#read config (source)
. "$config_file"

RANDOM=$(date +%s%N | cut -b10-19)

client_priv=$(wg genkey)
client_pub=$(echo "$client_priv" | wg pubkey)
client_port=$(($RANDOM % (65535 - 1500) + 1500))

preshared_key=$(wg genpsk)

function increaseIP() {
	echo "Incrase IP"
	baseaddr="$(echo $client_ip | cut -d. -f1-3)"
	lsv="$(echo $client_ip | cut -d. -f4)"

	lsv=$(($lsv + 1))
	client_ip=$baseaddr.$lsv
}

increaseIP

client_config=$(
	cat <<EOF
[Interface]
Address = $client_ip
ListenPort = $client_port
PrivateKey = $client_priv
DNS = $dns

[Peer]
AllowedIPs = $route_ips
Endpoint = $server_ip:$server_port
PersistentKeepalive = 25
PublicKey = $server_pub
PresharedKey = $preshared_key
EOF
)

cat <<EOF
#---------client-----------
$client_config

#---------server-----------
PublicKey = $client_pub
PresharedKey = $preshared_key

EOF

echo "$client_config" | qrencode --type=UTF8 --level=M

#write next ip to config file
sed -i "s/\(client_ip *= *\).*/\1$client_ip/" $config_file
