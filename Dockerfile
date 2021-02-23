FROM centos:latest

MAINTAINER tfournet@radersolutions.com

LABEL Remarks="Container for running Liongard ROAR Agents"

RUN dnf -y update 
RUN dnf -y install sudo npm wget

COPY install-roar /usr/local/bin/install-roar.sh
RUN  chmod +x /usr/local/bin/install-roar.sh

ENV HOME /root

WORKDIR /

ENTRYPOINT ["/usr/local/bin/install-roar.sh"]
