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


# Prepare installation directories
install_dir="/usr/local/containers/roar"
mkdir -p $install_dir
mkdir -p $install_dir/etc 

# Attempt to install prepreqs
which dnf && dnf -y install podman-compose curl
which yum && yum -y install docker docker-compose curl 
which apt && apt-get -y install docker docker-compose curl

# Attempt to enable container services
systemctl enable --now podman 2>/dev/null
systemctl enable --now docker 2>/dev/null 

# Grab compose file
curl -o $install_dir/docker-compose.yaml https://raw.githubusercontent.com/RaderSolutions/Liongard-Docker/main/docker-compose.yaml

echo """
INSTANCE=\"$1\"
AGENT_NAME=\"$(hostname)\"
DESCRIPTION=\"Docker Agent\"
ACCESS_KEY=\"$3\"
ACCESS_SECRET=\"$4\"
SERVICE_PROVIDER=\"$2\"
ENVIRONMENT=\"$5\"
USER=\"root\"
""" > $install_dir/etc/roar.conf 

cd $install_dir

echo "Attempting to start up images with docker-compose. If this fails you may need to do some distribution-specific troubleshooting on your host."


if (which docker-compose); then 
    docker-compose up -d
elif (which podman-compose); then
    podman-compose up -d
fi

docker ps 

