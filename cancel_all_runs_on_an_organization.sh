#!/usr/bin/env bash

# TOKEN=                                   # or set it on the commandline using export TOKEN=
TFE_HOST=tfe41.aws.munnep.com              # Change this to your TFE environment FQDN
ORG_NAME=test                             # Organization name 
RUN_STATUS_TO_CANCEL=pending,plan_queued,queuing,applying,planned # this needs to be a comma seperated list. See the complete list of options to choose from  https://developer.hashicorp.com/terraform/enterprise/api-docs/run#run-states
PAGE_SIZE=20                               # DO NOT ALTER:  number of items per page (default is 20, max is 100)
WORKSPACES=""                              # DO NOT ALTER:  var to store workspace ids


# get number of pages for PAGE_SIZE
PAGES=`curl -s \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  "https://$TFE_HOST/api/v2/organizations/$ORG_NAME/workspaces?page%5Bsize%5D=$PAGE_SIZE" | jq -r '.meta.pagination."total-pages"'`

# loop over number of PAGES to fetch all workspace ids
for (( page=1; page<=$PAGES ; page++ )); do
  echo "Processing page: $page"
  WORKSPACES_TEMP=`curl -s \
    --header "Authorization: Bearer $TOKEN" \
    --header "Content-Type: application/vnd.api+json" \
  "https://$TFE_HOST/api/v2/organizations/$ORG_NAME/workspaces?page%5Bsize%5D=$PAGE_SIZE&page%5Bnumber%5D=$page" | jq -r '.data[].id'`

  WORKSPACES="$WORKSPACES $WORKSPACES_TEMP"
done



# go over each workspace to verify if there is a pending run and cancel if it exists

for WORKSPACE in $WORKSPACES; do
   
  WORKSPACE_NAME=`curl -s\
    --header "Authorization: Bearer $TOKEN" \
    --header "Content-Type: application/vnd.api+json" \
    "https://$TFE_HOST/api/v2/workspaces/$WORKSPACE" | jq -r '.data.attributes.name'`

   echo "workspace $WORKSPACE_NAME being checked"

   # cancel runs that have a status of pending or plan_queued
   RUNS=`curl -s \
   --header "Authorization: Bearer $TOKEN" \
   --header "Content-Type: application/vnd.api+json" \
   "https://$TFE_HOST/api/v2/workspaces/$WORKSPACE/runs?filter%5Bstatus%5D=$RUN_STATUS_TO_CANCEL" | jq -r '.data[].id'`


   for RUN in $RUNS; do
     CANCEL_RUN=`curl -s \
     --header "Authorization: Bearer $TOKEN" \
     --header "Content-Type: application/vnd.api+json" \
     --request POST \
     --data '{  "comment": "This run was stuck and would never finish."}' \
     "https://$TFE_HOST/api/v2/runs/$RUN/actions/cancel"`
     
     echo "$RUN was given the cancel command on workspace $WORKSPACE_NAME"


   ##############
   # uncomment the force cancel command when you see certain jobs not being cancelled correctly and that need to be forced. Should not be needed
   ##############
     FORCE_CANCEL_RUN=`curl -s \
      --header "Authorization: Bearer $TOKEN" \
      --header "Content-Type: application/vnd.api+json" \
      --request POST \
      --data '{  "comment": "This run was stuck and would never finish."}' \
      https://$TFE_HOST/api/v2/runs/$RUN/actions/force-cancel`

      echo "$RUN was given the force cancel command on workspace $WORKSPACE"

   done

done