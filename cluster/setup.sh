#!/bin/bash

# Exit on error
set -e

# Variables
PROJECT_ID=$(gcloud config get-value project)
CLUSTER_NAME="boutique-cluster"
REGION="us-central1"
ZONE="us-central1-a"

echo "Creating GKE cluster..."
gcloud container clusters create $CLUSTER_NAME \
    --project $PROJECT_ID \
    --zone $ZONE \
    --machine-type e2-standard-2 \
    --num-nodes 4 \
    --enable-autoscaling \
    --min-nodes 4 \
    --max-nodes 6 \
    --enable-network-policy

echo "Getting cluster credentials..."
gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE --project $PROJECT_ID

# Define the target path
TARGET_DIR="/home/kmarouane/cloud-computing-project/microservices-demo"

# Check if the directory exists
if [ -d "$TARGET_DIR" ]; then
    echo "Directory exists: $TARGET_DIR"
    REPO_PATH="$TARGET_DIR"
else
    echo "Directory not found. Cloning microservices-demo repository to $TARGET_DIR..."
    git clone https://github.com/GoogleCloudPlatform/microservices-demo.git "$TARGET_DIR"
    REPO_PATH="$TARGET_DIR"
fi

# Deploy the application
echo "Deploying application..."
kubectl apply -f "$REPO_PATH/release/kubernetes-manifests.yaml"

echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod --all --timeout=300s

echo "Getting frontend service external IP..."
kubectl get service frontend-external | awk '{print $4}'

echo "Setup complete!"