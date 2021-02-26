FROM node:14

LABEL Remarks="Container for running Liongard ROAR Agents"

#RUN yum -y update 
#RUN yum -y install sudo npm wget

RUN apt-get -y install sudo
RUN mkdir -p /etc/liongard 

COPY install-roar /usr/local/bin/install-roar.sh
RUN  chmod +x /usr/local/bin/install-roar.sh
RUN  chmod +r /etc/liongard/*

ENV HOME /root

WORKDIR /

ENTRYPOINT ["/usr/local/bin/install-roar.sh"]

