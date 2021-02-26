#!/bin/bash
#
# Roar Agent Setup Script
#
# This script will setup a Roar agent which is used by Roar
# to run inspectors against various sources.
#
# For more information please run:
# ./setup-roar-agent --help
#
# Example (Installing an Agent)
# sudo -u ubuntu ./setup-roar-agent --url "yourdomain.liongard.com" --name "MY_AGENT_NAME" --description "This agent is for XXX" --access-key "XXXXXXXXXXX" --access-secret "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" --service-provider "My Service Provider" --environment "My Environment Name"
####

usage() {
    echo "Usage: $0 [--url <string>] [--name <string>] [--service-provider <string>] [--environment <string>] [--description <string>] [--access-key <string>] [--access-secret <string>] [--install-path <string>] [--containers] [--managed] [--keycode <string>]" >&2
    echo
    echo "   -u, --url           The url of your running Roar instance, e.g. acmeinc.liongard.com"
    echo "   -n, --name          The name of the agent"
    echo "   -d, --description   (Optional)A description about the agent, consider putting in network access information in here, i.e. 192.156.0.0/32"
    echo "   -p, --service-provider    Name of your service provider in Roar"
    echo "   -e, --environment    Name of environment you would like to constrain this agent to. Optional."
    echo "   -k, --access-key    Access key from Roar"
    echo "   -s, --access-secret Access secret from Roar"
    echo "   -i, --install-path Path to Agent installation"
    echo "   -c, --containers    Install support for running containerized inspectors"
    echo "   -m, --managed    Agent is managed by Roar Support"
    echo "   -kc, --keycode    Roar Support Authentication Token"
    echo
    exit 1
}

OPTS=`getopt -o u:n:d:p:e:k:s:i:c:mkc:h --long url:,name:,description:,service-provider:,environment:,access-key:,access-secret:,install-path:,containers:,managed,keycode:,help -n 'roar-agent' -- "$@"`

if [ $? != 0 ] ; then
  usage
  echo "Failed parsing options." >&2
  exit 1
fi

# use eval with "$PARSED" to properly handle the quoting
eval set -- "$OPTS"

DESCRIPTION=""
DOCKER=false
MANAGED=false
KEYCODE=""
HELP=false
CONFIGDIR=/etc/liongard/roar
INSTALL_DIR=/opt/liongard

# Error codes
ERROR_RAN_AS_NON_ADMIN_USER=1
ERROR_FAILED_TO_REGISTER=2
ERROR_FAILED_TO_START_SERVICE=3

while true; do
  case "$1" in
    -u | --url ) URL="$2"; shift; shift ;;
    -n | --name ) NAME="$2"; shift; shift ;;
    -d | --description ) DESCRIPTION="$2"; shift; shift ;;
    -p | --service-provider ) SERVICE_PROVIDER="$2"; shift; shift ;;
    -e | --environment ) ENVIRONMENT="$2"; shift; shift ;;
    -k | --access-key ) ACCESS_KEY="$2"; shift; shift ;;
    -s | --access-secret ) ACCESS_SECRET="$2"; shift; shift ;;
    -i | --install-path ) INSTALL_DIR="$2"; shift; shift ;;
    -c | --containers ) DOCKER=true; shift ;;
    -m | --managed ) MANAGED=true; shift ;;
    -kc | --keycode ) KEYCODE="$2"; shift; shift ;;
    -h | --help ) HELP=true; shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

if [ "$HELP" = 'true' ]; then
  usage
fi

echo URL=$URL
echo NAME=$NAME
echo DESCRIPTION=$DESCRIPTION
echo SERVICE_PROVIDER=$SERVICE_PROVIDER
echo ENVIRONMENT=$ENVIRONMENT
echo ACCESS_KEY=$ACCESS_KEY
echo ACCESS_SECRET=$ACCESS_SECRET
echo INSTALL_DIR=$INSTALL_DIR
echo DOCKER=$DOCKER
echo MANAGED=$MANAGED
echo KEYCODE=$KEYCODE

if [ -z ${URL+x} ]; then
  echo "You must specify the API url with the --url argument"
  usage
  exit 1
fi

if [ -z ${NAME+x} ] && [ ! "$REMOVE" = 'true' ]; then
  echo "You must specify the agent name with the -n argument"
  usage
  exit 1
fi

if [ -z ${SERVICE_PROVIDER+x} ]; then
  echo "You must specify your roar service provider with the -p argument"
  usage
  exit 1
fi

if [ -z ${ACCESS_KEY+x} ]; then
  echo "You must specify your roar access key with the -k argument"
  usage
  exit 1
fi

if [ -z ${ACCESS_SECRET+x} ]; then
  echo "You must specify your roar access secret with the -s argument"
  usage
  exit 1
fi

echo "Checking root privileges available."
SUDO=$(sudo sh -c 'echo "Testing...."')
if [ $? -ne 0 ]; then
  echo "Script user does not have root access."
  exit $ERROR_RAN_AS_NON_ADMIN_USER
else
  echo "Got root!"
fi

echo "Get Latest Version Number..."
{
  wget --output-document=node-updater.html https://nodejs.org/dist/latest/

  ARCH=$(uname -m)

  if [ $ARCH = x86_64 ]
  then
    grep -o '>node-v.*-linux-x64.tar.gz' node-updater.html > node-cache.txt 2>&1
    VER=$(grep -o 'node-v.*-linux-x64.tar.gz' node-cache.txt)
  elif [ $ARCH = armv7l ]
  then
    grep -o '>node-v.*-linux-armv7l.tar.gz' node-updater.html > node-cache.txt 2>&1
    VER=$(grep -o 'node-v.*-linux-armv7l.tar.gz' node-cache.txt)
  elif [ $ARCH = arm64 ]
  then
    grep -o '>node-v.*-linux-arm64.tar.gz' node-updater.html > node-cache.txt 2>&1
    VER=$(grep -o 'node-v.*-linux-armv7l.tar.gz' node-cache.txt)
  else
    grep -o '>node-v.*-linux-x86.tar.gz' node-updater.html > node-cache.txt 2>&1
    VER=$(grep -o 'node-v.*-linux-x86.tar.gz' node-cache.txt)
  fi
  rm ./node-cache.txt
  rm ./node-updater.html
} &> /dev/null

DIR=$( cd "$( dirname $0 )" && pwd )

echo "Downloading latest stable Version $VER..."
{
wget https://nodejs.org/dist/latest/$VER -O $DIR/$VER
} &> /dev/null

echo "Installing latest stable NodeJS..."
cd /usr/local && sudo tar --strip-components 1 -xzf $DIR/$VER

rm $DIR/$VER

echo "Installing PM2"
sudo npm install -g pm2

echo "Installing Roar CLI"
sudo npm install -g @liongard/roarcli@latest

if [ "$DOCKER" = 'true' ]; then
  echo "Installing Docker"
  sudo curl -fsSL get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  USER=$(whoami)
  sudo usermod -a -G docker $USER
fi

# Set up dir where agent ID will be stored
sudo mkdir --parents $CONFIGDIR
sudo mkdir --parents $INSTALL_DIR
sudo chown -R $USER:$(id -gn $USER) $CONFIGDIR
sudo chown -R $USER:$(id -gn $USER) $INSTALL_DIR

echo "Setting up the agent"
if [ "$MANAGED" = true ] ; then
  IN="$(sudo -u $USER roar setup-agent "$NAME" "$DESCRIPTION" --api "$URL" --service_provider "$SERVICE_PROVIDER" --access_key "$ACCESS_KEY" --access_key_secret "$ACCESS_SECRET" --install_path "$INSTALL_DIR" --managed --keycode "$KEYCODE")"
elif [ -z "$ENVIRONMENT" ]; then
  IN="$(sudo -u $USER roar setup-agent "$NAME" "$DESCRIPTION" --api "$URL" --service_provider "$SERVICE_PROVIDER" --access_key "$ACCESS_KEY" --access_key_secret "$ACCESS_SECRET" --install_path "$INSTALL_DIR")"
else
  IN="$(sudo -u $USER roar setup-agent "$NAME" "$DESCRIPTION" --api "$URL" --service_provider "$SERVICE_PROVIDER" --access_key "$ACCESS_KEY" --access_key_secret "$ACCESS_SECRET" --install_path "$INSTALL_DIR" --environment "$ENVIRONMENT")"
fi

if [ $? -eq 0 ]; then
  while IFS=':' read -ra ADDR; do
    if [ "${ADDR[0]}" == "ID" ]; then
      ID="${ADDR[1]}"
    fi
  done <<< "$IN"
else
  echo "Received exit code $?. Failed to register the agent with Roar"
  exit $ERROR_FAILEDTOREGISTER
fi

echo "Adding agent id to the config file"
echo "$ID" | sudo tee $CONFIGDIR/.agent

echo "Starting the agent..."
pm2 start "$INSTALL_DIR/scripts/service.json"
sudo env PATH=$PATH:/usr/bin /usr/local/lib/node_modules/pm2/bin/pm2 startup systemd -u $USER --hp $HOME
pm2 save

echo "Roar Agent Setup Completed"
