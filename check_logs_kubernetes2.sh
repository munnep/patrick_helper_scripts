#!/bin/bash

# Specify the namespace you want to monitor
NAMESPACE="terraform-enterprise"
# Specify the pods to ignore
IGNORED_PODS=("tfc-agent-deployment-57d779f795-4hwtj" "terraform-enterprise3-6db8847d65-g4w65" "yet-another-pod")
# Specify the logfile to tail. Default is terraform-enterprise.log which should contain the logs you need
LOGFILE="terraform-enterprise.log"

# Function to get the name of the first pod found in the namespace, excluding the ignored pods
get_pod_name() {
  PODS=$(kubectl get pods -n "$NAMESPACE" --no-headers -o custom-columns=":metadata.name")
  for pod in "${IGNORED_PODS[@]}"; do
    PODS=$(echo "$PODS" | grep -v "$pod")
  done
  echo "$PODS" | head -n 1
}

# Loop until a pod is detected
while true; do
  POD_NAME=$(get_pod_name)
  if [ -n "$POD_NAME" ]; then
    echo "Pod '$POD_NAME' detected in namespace '$NAMESPACE'. Fetching logs:"
    kubectl -n "$NAMESPACE" exec -it "$POD_NAME" -- tail -f /var/log/terraform-enterprise/"$LOGFILE"
    break
  else
    echo "No pods found in namespace '$NAMESPACE' (excluding ignored pods). Retrying in 2 seconds..."
    sleep 2
  fi
done