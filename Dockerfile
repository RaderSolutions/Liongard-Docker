FROM centos:latest

MAINTAINER tfournet@radersolutions.com

LABEL Remarks="Container for running Liongard ROAR Agents"

RUN dnf -y update 

COPY install-roar install-roar.sh
RUN  chmod +x install-roar.sh

ENV HOME /root

WORKDIR /root

ENTRYPOINT ["/usr/local/bin/install-roar.sh"]
