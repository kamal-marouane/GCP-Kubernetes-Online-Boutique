resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region
  project  = var.project_id

  # Remove default node pool after cluster creation
  remove_default_node_pool = true
  initial_node_count       = 1

  node_config {
    machine_type = "e2-standard-2"
    disk_size_gb = 30
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  cluster    = google_container_cluster.primary.name
  location   = var.region
  project    = var.project_id
  node_locations = ["${var.region}-a"]

  # Explicitly control the number of nodes
  node_count = 4

  node_config {
    preemptible  = true
    machine_type = "e2-standard-2"
    disk_size_gb = 10
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}

output "kubeconfig" {
  value = google_container_cluster.primary.endpoint
}

output "endpoint" {
  value = google_container_cluster.primary.endpoint
}