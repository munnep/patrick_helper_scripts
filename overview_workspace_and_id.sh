#!/usr/bin/env bash

# TOKEN=<your API token>      # or set it on the commandline using export TOKEN=
TFE_HOST=app.terraform.io   # Change this to your TFE environment FQDN
ORG_NAME=patrickmunne       # Organization name 
PAGE_SIZE=100                 # number of items per page (default is 20, max is 100)
WORKSPACES=""               #var to store workspace ids

echo "List workspace name and ID: $ORG_NAME"

# get number of pages for PAGE_SIZE
PAGES=`curl -s \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  "https://$TFE_HOST/api/v2/organizations/$ORG_NAME/workspaces?page%5Bsize%5D=$PAGE_SIZE" | jq -r '.meta.pagination."total-pages"'`


# loop over number of PAGES to fetch all ids
for (( page=1; page<=$PAGES ; page++ )); do
  echo "Processing page: $page"
  WORKSPACES_TEMP=`curl -s \
    --header "Authorization: Bearer $TOKEN" \
    --header "Content-Type: application/vnd.api+json" \
  "https://$TFE_HOST/api/v2/organizations/$ORG_NAME/workspaces?page%5Bsize%5D=$PAGE_SIZE&page%5Bnumber%5D=$page" | jq -r '.data[].id'`

  WORKSPACES="$WORKSPACES $WORKSPACES_TEMP"
done

# Loop over the workspace ID to get the workspace name
for WORKSPACE in $WORKSPACES; do

  WORKSPACE_NAME=`curl -s \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  "https://$TFE_HOST/api/v2/workspaces/$WORKSPACE" | jq -r '.data.attributes.name'`

  echo "WORKSPACE_NAME=$WORKSPACE_NAME WORKSPACE_ID=$WORKSPACE"
done