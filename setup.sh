#!/bin/sh


if [[ $# -ne 5 ]]; then
    echo "ERROR: Need to pass the correct parameters. Usage: ./setup.sh \"<INSTANCE>\" \"<SERVICE_PROVIDER>\" <ACCESS_KEY> <ACCESS_SECRET> <ENVIRONMENT>"
    echo """
            INSTANCE = Your Liongard instance. You only need to include the first part of the subdomain, \"app.liongard.com\" is assumed
            SERVICE_PROVIDER = The name of your company as it appears in the top left corner of your Liongard instance
            ACCESS_KEY = Your Access Key from Liongard
            ACCESS_SECRET = Your Access Secret from Liongard
            ENVIRONMENT = The name of the Environment in Liongard to associate the Agent to
            Quotes around spaced names are required.
"""
    exit 2
fi



installdir="/usr/local/containers/roar"

echo "Checking for docker/podman components on your system and attempting to install if needed..."
if ! (which docker-compose); then
  echo "Docker Compose was not found on your system. Attempting to install it using standard distro utils"
  which dnf && dnf -y install podman-compose curl
  which yum && yum -y install docker docker-compose curl 
  which apt && apt-get -y install docker docker-compose curl
  if ! (which docker-compose); then 
    echo "Still unable to find docker-compose on this system. You will need to install docker-compose manually. Exiting"
    exit 100
  fi
fi

compose=$(which docker-compose)


cp docker-compose.yaml $installdir

echo """
INSTANCE=\"$1\"
AGENT_NAME=\"$(hostname)\"
DESCRIPTION=\"Docker Agent\"
ACCESS_KEY=\"$3\"
ACCESS_SECRET=\"$4\"
SERVICE_PROVIDER=\"$2\"
ENVIRONMENT=\"$5\"
""" > $installdir/etc/roar.conf 


