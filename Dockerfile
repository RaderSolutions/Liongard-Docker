FROM centos:latest

LABEL Remarks="Container for running Liongard ROAR Agents"

RUN yum -y update 
RUN yum -y install sudo npm wget net-tools bindutils whois

#RUN apt-get update && apt-get -y install sudo
RUN mkdir -p /etc/liongard 

RUN echo 'pathmunge /usr/local/bin' > /etc/profile.d/roar.sh
RUN chmod +x /etc/profile.d/roar.sh 

COPY install-roar /usr/local/bin/install-roar.sh
RUN  chmod +x /usr/local/bin/install-roar.sh

ENV HOME /root

WORKDIR /

ENTRYPOINT ["/usr/local/bin/install-roar.sh"]

