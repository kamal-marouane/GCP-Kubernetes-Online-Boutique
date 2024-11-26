#!/bin/bash

# Exit on error
set -e

# Variables
PROJECT_ID=$(gcloud config get-value project)
CLUSTER_NAME="boutique-cluster"
REGION="us-central1"
ZONE="us-central1-a"
MANIFEST_PATH="/home/kmarouane/cloud-computing-project/microservices-demo/release/kubernetes-manifests.yaml"

# Function to check if resources exist
check_resources() {
    # Get all resources that would be affected by the manifest
    kubectl get -f "$MANIFEST_PATH" --no-headers 2>/dev/null
    return $?
}

# Function to wait for resources deletion with timeout
wait_for_deletion() {
    local timeout=300  # 5 minutes timeout
    local start_time=$(date +%s)
    local current_time
    
    echo "Waiting for resources to be deleted..."
    while true; do
        if ! check_resources &>/dev/null; then
            echo "All resources have been successfully deleted."
            return 0
        fi
        
        current_time=$(date +%s)
        if [ $((current_time - start_time)) -gt $timeout ]; then
            echo "Warning: Timeout reached while waiting for resources deletion."
            echo "Some resources might still exist. Proceeding with cluster deletion..."
            return 1
        fi
        
        echo "Resources still exist. Waiting..."
        sleep 10
    done
}

# Function to check if cluster exists
cluster_exists() {
    gcloud container clusters describe "$CLUSTER_NAME" \
        --project "$PROJECT_ID" \
        --zone "$ZONE" &>/dev/null
    return $?
}

# Main cleanup process
echo "Starting cleanup process..."

# Only proceed with cleanup if the cluster exists
if cluster_exists; then
    echo "Found cluster: $CLUSTER_NAME"
    
    # Delete all resources in the cluster first
    if [ -f "$MANIFEST_PATH" ]; then
        echo "Deleting all resources defined in manifest..."
        kubectl delete -f "$MANIFEST_PATH" --ignore-not-found=true || true
        
        # Wait for resources to be deleted
        wait_for_deletion
    else
        echo "Warning: Manifest file not found at $MANIFEST_PATH"
        echo "Proceeding with cluster deletion..."
    fi
    
    # Delete the GKE cluster
    echo "Deleting GKE cluster: $CLUSTER_NAME"
    gcloud container clusters delete "$CLUSTER_NAME" \
        --project "$PROJECT_ID" \
        --zone "$ZONE" \
        --quiet \
        --async
    
    # Wait for cluster deletion to complete
    echo "Waiting for cluster deletion to complete..."
    while cluster_exists; do
        echo "Cluster is still being deleted... Waiting..."
        sleep 5
    done
    
    echo "Cluster deletion completed successfully."
else
    echo "Cluster $CLUSTER_NAME does not exist. Nothing to clean up."
fi

echo "Cleanup process completed!"
echo "Verify in the Google Cloud Console that no resources are still running at:"
echo "https://console.cloud.google.com/kubernetes/list?project=$PROJECT_ID"