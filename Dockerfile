FROM ubuntu:22.04

RUN apt update && apt install -y wireguard openresolv iptables wget iproute2

RUN wget https://github.com/cbeuw/Cloak/releases/download/v2.7.0/ck-server-linux-amd64-v2.7.0
RUN mv ck-server-linux-amd64-v2.7.0 ck-server
RUN chmod +x ck-server

COPY gen-ck-server-config.sh /gen-ck-server-config.sh
RUN chmod +x /gen-ck-server-config.sh

COPY gen-wg-server-config.sh /gen-wg-server-config.sh
RUN chmod +x /gen-wg-server-config.sh

COPY up.sh /up.sh
RUN chmod +x /up.sh

CMD ["/up.sh"]