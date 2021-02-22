#!/bin/sh

INSTANCE="us4"
AGENT_NAME="myagentname"
DESCRIPTION="This agent is for XXX"
ACCESS_KEY=""
ACCESS_SECRET=""
SERVICE_PROVIDER=""
ENVIRONMENT=""
USER="ubuntu"
curl -k https://$INSTANCE.app.liongard.com/api/v1/agents/scripts/setup-roar-agent/ -o setup-roar-agent
chmod 775 setup-roar-agent
sudo -u $USER ./setup-roar-agent --url "$INSTANCE.app.liongard.com" --name "$AGENT_NAME" --description "$DESCRIPTION" --access-key $ACCESS_KEY --access-secret $ACCESS_SECRET --service-provider "$SERVICE_PROVIDER" --environment "$ENVIRONMENT"
