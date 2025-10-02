#!/bin/bash

# Specify the namespace you want to monitor
NAMESPACE="terraform-enterprise"
# Specify the pod to ignore
IGNORED_POD="terraform-enterprise-77bfd98ff4-6nzdx"

# Function to get the name of the first pod found in the namespace, excluding the ignored pod
get_pod_name() {
  kubectl get pods -n "$NAMESPACE" --no-headers -o custom-columns=":metadata.name" | grep -v "$IGNORED_POD" | head -n 1
}

# Loop until a pod is detected
while true; do
  POD_NAME=$(get_pod_name)
  if [ -n "$POD_NAME" ]; then
    echo "Pod '$POD_NAME' detected in namespace '$NAMESPACE'. Fetching logs:"
    kubectl logs -f "$POD_NAME" -n "$NAMESPACE"
    break
  else
    echo "No pods found in namespace '$NAMESPACE' (excluding '$IGNORED_POD'). Retrying in 2 seconds..."
    sleep 2
  fi
done
