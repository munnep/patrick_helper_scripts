#!/usr/bin/env bash

# TOKEN=<your API token>      # or set it on the commandline using export TOKEN=
TFE_HOST=app.terraform.io   # Change this to your TFE environment FQDN
ORG_NAME=patrickmunne       # Organization name 
OUTPUT_FILE=output.txt      # name of the file to output the data



echo "List workspaces and runs for organization: $ORG_NAME"

WORKSPACES=`curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  https://$TFE_HOST/api/v2/organizations/$ORG_NAME/workspaces | jq -r '.data[].id'`

# clear the file
echo "--- OVERVIEW WORKSPACES on $ORG_NAME and RUNS by date ----" > $OUTPUT_FILE


for WORKSPACE in $WORKSPACES; do

  WORKSPACE_NAME=`curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  https://$TFE_HOST/api/v2/organizations/$ORG_NAME/workspaces | jq -r --arg WORKSPACE_ID "$WORKSPACE" '[.data[]| select(.id==$WORKSPACE_ID)]' | jq -r '.[].attributes.name'`

  echo "WORKSPACE_NAME=$WORKSPACE_NAME" >> $OUTPUT_FILE

  RUNS=`curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  https://$TFE_HOST/api/v2/workspaces/$WORKSPACE/runs | jq -r '.data[].id'`

  for RUN in $RUNS; do
    RUN_DATE=`curl \
    --header "Authorization: Bearer $TOKEN" \
    https://$TFE_HOST/api/v2/runs/$RUN | jq -r '.data.attributes."created-at"'`
    
    echo "    RUN DATE: $RUN_DATE" - RUN ID: $RUN >> $OUTPUT_FILE
  done

done
