#!/usr/bin/env bash

# TOKEN=<your API token>      # or set it on the commandline using export TOKEN=
TFE_HOST=app.terraform.io   # Change this to your TFE environment FQDN
ORG_NAME=patrickmunne       # Organization name 
OUTPUT_FILE=output.txt      # name of the file to output the data
PAGE_SIZE=5                 # number of items per page (default is 20, max is 100)
WORKSPACES=""               #var to store workspace ids

echo "List workspaces and runs for organization: $ORG_NAME"

# get number of pages for PAGE_SIZE
PAGES=`curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  "https://$TFE_HOST/api/v2/organizations/$ORG_NAME/workspaces?page%5Bsize%5D=$PAGE_SIZE" | jq -r '.meta.pagination."total-pages"'`


# loop over number of PAGES to fetch all ids
for (( page=1; page<=$PAGES ; page++ )); do
  echo "Processing page: $page"
  WORKSPACES_TEMP=`curl \
    --header "Authorization: Bearer $TOKEN" \
    --header "Content-Type: application/vnd.api+json" \
  "https://$TFE_HOST/api/v2/organizations/$ORG_NAME/workspaces?page%5Bsize%5D=$PAGE_SIZE&page%5Bnumber%5D=$page" | jq -r '.data[].id'`

  WORKSPACES="$WORKSPACES $WORKSPACES_TEMP"
done


# clear the file
echo "--- OVERVIEW WORKSPACES on $ORG_NAME and RUNS by date ----" > $OUTPUT_FILE
echo $WORKSPACES

for WORKSPACE in $WORKSPACES; do

  WORKSPACE_NAME=`curl \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  "https://$TFE_HOST/api/v2/workspaces/$WORKSPACE" | jq -r '.data.attributes.name'`

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
