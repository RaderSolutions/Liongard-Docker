FROM centos:8-stream

MAINTAINER tfournet@radersolutions.com

LABEL Remarks="Container for running Liongard ROAR Agents"

RUN dnf -y update 

COPY install-roar.sh /usr/local/bin/install-roar.sh


ENV HOME /root

WORKDIR /root
