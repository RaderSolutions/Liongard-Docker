FROM centos:7

LABEL Remarks="Container for running Liongard ROAR Agents"

RUN yum -y update 
RUN yum -y install sudo npm wget

COPY install-roar /usr/local/bin/install-roar.sh
RUN  chmod +x /usr/local/bin/install-roar.sh

ENV HOME /root

WORKDIR /

ENTRYPOINT ["/usr/local/bin/install-roar.sh"]

