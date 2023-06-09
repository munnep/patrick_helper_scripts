#!/usr/bin/env bash

# TOKEN=<your API token>             # or set it on the commandline using export TOKEN=
TFE_HOST=app.terraform.io            # Change this to your TFE environment FQDN
ORG_NAME=patrickmunne                # Organization name 
WORKSPACE_ID="ws-2LA6XrC1RKvpXw4b"   # WORKSPACE ID of workspace you want to cancel all pending runs


# clear the file
echo "--- Cancel all pending runs on workspace $WORKSPACE_ID ----"

RUNS=`curl -s \
--header "Authorization: Bearer $TOKEN" \
--header "Content-Type: application/vnd.api+json" \
"https://$TFE_HOST/api/v2/workspaces/$WORKSPACE_ID/runs?filter%5Bstatus%5D=pending" | jq -r '.data[].id'`


for RUN in $RUNS; do
  CANCEL_RUN=`curl -s \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data '{  "comment": "This run was stuck and would never finish."}' \
  "https://app.terraform.io/api/v2/runs/$RUN/actions/cancel"`
  
  echo "$RUN was given the cancel command"
done
