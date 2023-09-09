#!/bin/bash

set -e

if [ -z "${WG_SERVER_PRIVATE_KEY}" ]; then
    echo "Error: environment variable WG_SERVER_PRIVATE_KEY is required."
    exit 1
fi

if [ -z "${WG_CLIENT_PUBLIC_KEY}" ]; then
    echo "Error: environment variable WG_CLIENT_PUBLIC_KEY is required."
    exit 1
fi

cat << EOF > wg0.conf
[Interface]
Address = 10.66.66.1/24
ListenPort = 55165
PrivateKey = ${WG_SERVER_PRIVATE_KEY}
PostUp = iptables -I INPUT -p udp --dport 55165 -j ACCEPT
PostUp = iptables -I FORWARD -i eth+ -o wg0 -j ACCEPT
PostUp = iptables -I FORWARD -i wg0 -j ACCEPT
PostUp = iptables -t nat -A POSTROUTING -o eth+ -j MASQUERADE
PostDown = iptables -D INPUT -p udp --dport 55165 -j ACCEPT
PostDown = iptables -D FORWARD -i eth+ -o wg0 -j ACCEPT
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT
PostDown = iptables -t nat -D POSTROUTING -o eth+ -j MASQUERADE

[Peer]
PublicKey = ${WG_CLIENT_PUBLIC_KEY}
AllowedIPs = 10.66.66.2/32
EOF

echo "Configuration file wg0.conf created successfully."