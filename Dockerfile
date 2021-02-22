FROM centos:latest

MAINTAINER tfournet@radersolutions.com

LABEL Remarks="Container for running Liongard ROAR Agents"

RUN dnf -y update 

COPY install-roar /usr/local/bin/install-roar.sh
RUN  chmod +x /usr/local/bin/install-roar.sh

ENV HOME /root

WORKDIR /root

ENTRYPOINT ["/usr/local/bin/install-roar.sh --url \"$INSTANCE.app.liongard.com\" --name \"$AGENT_NAME\" --description \"$DESCRIPTION\" --access-key $ACCESS_KEY --access-secret $ACCESS_SECRET --service-provider \"$SERVICE_PROVIDER\" --environment \"$ENVIRONMENT\""]
