#!/bin/bash

set -e

/gen-wg-server-config.sh
/gen-ck-server-config.sh

_term() {
    echo "Stopping services..."
    wg-quick down /wg0.conf
    kill -TERM "$ck_server_pid" 2>/dev/null
    echo "Services stopped."
}
trap _term SIGTERM

wg-quick up /wg0.conf
./ck-server -c ./ck-server.json &

ck_server_pid=$!

wait "$ck_server_pid"