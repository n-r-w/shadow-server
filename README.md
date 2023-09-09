# Cloak + WireGuard + Docker  + LAN gateway (server-side)

## Server-side setup for internet access through a separate gateway in the local network. Client-side here <https://github.com/n-r-w/shadow-client>

Data flows through the following chain:

- Computer (LAN) with the client part of this configuration specified as the gateway
- Gateway (LAN)
- WireGuard client (LAN)
- Cloak client (LAN)
- Censored Internet
- Cloak server (remote)
- WireGuard server (remote)
- Free Internet

For simplicity, all operations are performed as root, using Ubuntu 22.04 as an example. All settings are for IPv4 only. First, you need to follow this guide, and then the client-side part <https://github.com/n-r-w/shadow-client>

Tested on:

- Remote server Ununtu 22.04 (VPS, 1 CPU core, 1GB RAM)
- Local server Ubuntu 20.04 (2 CPU cores, 2GB RAM, single ethernet port).
- Speedtest Download Mbps: 108, Upload Mbps: 71. This is slower than a direct WireGuard connection (Download Mbps: 254, Upload Mbps: 189) because the traffic goes through Cloak and is encrypted to make it indistinguishable from regular HTTP traffic, disguising it as a VPN connection. The bottleneck here is the server's CPU. If a dual-core configuration is used, the speed should be higher.

## Configuring the Firewall

```bash
ufw allow openssh
ufw allow http
ufw allow https
ufw enable
```

## Server Preparation

```bash
cd /root
apt update
apt install -y nano wget git wireguard
wget https://github.com/cbeuw/Cloak/releases/download/v2.7.0/ck-server-linux-amd64-v2.7.0
RUN mv ck-server-linux-amd64-v2.7.0 ck-server
RUN chmod +x ck-server
```

We've downloaded WireGuard and Cloak server for generating encryption keys. Once generated, they are no longer needed on the host.

Enable ip forward

- ```nano /etc/sysctl.conf```
- edit: ```net.ipv4.ip_forward=1```
- apply changes: ```sysctl -p```

## docker setup

### Install docker Manually

- Install docker itself using the instructions at  <https://docs.docker.com/engine/install/ubuntu/>:

```bash
# Add Docker's official GPG key:
apt-get update
apt-get install ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

- Install docker-compose

```bash
wget https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-linux-x86_64
mv docker-compose-linux-x86_64 /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

### Alternatively, install docker via snap (easier)

```bash
apt install snapd
snap install docker
```

## Generation of encryption keys

### Generating wireguard keys

```bash
wg genkey | tee wg-server-private.key | wg pubkey > wg-server-public.key
wg genkey | tee wg-client-private.key | wg pubkey > wg-client-public.key
```

- ```wg-server-private.key``` server private key
- ```wg-server-public.key``` server public key. Will be needed when installing the client part <https://github.com/n-r-w/shadow-client>
- ```wg-client-private.key``` client private key. Will be needed when installing the client part <https://github.com/n-r-w/shadow-client>
- ```wg-client-public.key``` client public key

### Generating cloak keys

```bash
./ck-server -k > cloak.keys
./ck-server -u > cloak.uid
```

- ```cloak.keys``` cloak keys pair. public key (will be needed when installing the client part <https://github.com/n-r-w/shadow-client>), private key
- ```cloak.uid``` cloak client UID

## Setup

### Download this repository

```bash
git clone https://github.com/n-r-w/shadow-server.git
cd shadow-server
```

### Set up environment variables for docker

In the doc directory there is an example file with environment variables ```env.txt```. Copy it to the ```.env``` file, which contains environment variables for ```docker-compose```

```bash
cp ./doc/env.txt ./.env
nano ./.env
```

Setting the values ​​of the variables

- ```CK_UID``` take from file ```cloak.uid```
- ```CK_PRIVATE_KEY``` take from file (second key) ```cloak.keys```
- ```WG_SERVER_PRIVATE_KEY``` take from file ```wg-server-private.key```
- ```WG_CLIENT_PUBLIC_KEY``` take from file ```wg-client-public.key```

## Test run

We check that everything starts (the first launch is long)

```bash
docker-compose up
```

Press CTRL+C and then

```bash
docker-compose down
```

## Create systemd service to automatically launch a container

If installed via ```snap```:

```bash
cp ./doc/shadow-server-snap.service /etc/systemd/system/shadow-server-snap.service
systemctl daemon-reload
systemctl enable shadow-server-snap
systemctl start shadow-server-snap
```

If you installed it according to the instructions from the ubuntu website:

```bash
cp ./doc/shadow-server.service /etc/systemd/system/shadow-server.service
systemctl daemon-reload
systemctl enable shadow-server
systemctl start shadow-server
```

That's it, now we need to proceed to installing the client <https://github.com/n-r-w/shadow-client>
