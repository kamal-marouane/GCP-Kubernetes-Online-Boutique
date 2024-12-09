terraform {
  required_version = ">= 0.12"
  backend "gcs" {
    bucket = "GCP-Online-Boutique-state-bucket"
    prefix = "terraform/state"
  }
}

module "gke" {
  source = "./gke"
  project_id = var.project_id
  region     = var.region
  cluster_name = var.cluster_name
}