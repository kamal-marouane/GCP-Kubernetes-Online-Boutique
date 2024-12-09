# Variables
PROJECT_ID=$(gcloud config get-value project)
CLUSTER_NAME="boutique-cluster"
REGION="us-central1"

echo "Getting cluster credentials..."
gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION --project $PROJECT_ID

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