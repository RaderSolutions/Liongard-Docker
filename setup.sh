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
mkdir -p $install_dir/logs 

# Attempt to install prepreqs
which dnf >/dev/null 2>&1 && dnf -y install podman-compose curl
which yum >/dev/null 2>&1 && yum -y install docker docker-compose curl 
which apt >/dev/null 2>&1 && apt-get -y install docker docker-compose curl

# Attempt to enable container services
systemctl enable --now podman 2>/dev/null
systemctl enable --now docker 2>/dev/null 

# Grab compose file
curl -o $install_dir/docker-compose.yaml https://raw.githubusercontent.com/RaderSolutions/Liongard-Docker/main/docker-compose.yaml

echo """
INSTANCE=\"$1\"
AGENT_NAME=\"$(hostname)-pod\"
DESCRIPTION=\"Docker Agent\"
ACCESS_KEY=\"$3\"
ACCESS_SECRET=\"$4\"
SERVICE_PROVIDER=\"$2\"
ENVIRONMENT=\"$5\"
USER=\"root\"
""" > $install_dir/etc/roar-container.conf 

chmod a+r $install_dir/etc/roar-container.conf 

cd $install_dir

cat $install_dir/etc/roar-container.conf 

echo ""
echo "Attempting to start up images with docker-compose. If this fails you may need to do some distribution-specific troubleshooting on your host."


if (which docker-compose  >/dev/null 2>&1); then 
    docker-compose up -d
elif (which podman-compose >/dev/null 2>&1); then
    podman-compose up -d
fi

docker ps 

