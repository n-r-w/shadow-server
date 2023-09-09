#!/bin/bash

set -e

if [ -z "${CK_UID}" ]; then
    echo "Error: environment variable CK_UID is required."
    exit 1
fi

if [ -z "${CK_PRIVATE_KEY}" ]; then
    echo "Error: environment variable CK_PRIVATE_KEY is required."
    exit 1
fi

if [ -z "${CK_REDIR_ADDR}" ]; then
    CK_REDIR_ADDR="cloudflare.com" 
    echo "CK_REDIR_ADDR is not set. Defaulting to ${CK_REDIR_ADDR}."
fi

cat << EOF > ck-server.json
{
  "ProxyBook": {
    "wireguard": [
      "udp",
      "127.0.0.1:55165"
    ]
  },
  "BindAddr": [
    ":443",
    ":80"
  ],
  "BypassUID": [
    "${CK_UID}"
  ],
  "RedirAddr":"${CK_REDIR_ADDR}",
  "PrivateKey": "${CK_PRIVATE_KEY}"
}
EOF

echo "Configuration file ck-server.json created successfully."