terraform {
  required_version = ">= 0.12"
  backend "gcs" {
    bucket = "gcp-online-boutique-state-bucket"
    prefix = "terraform/state"
  }
}

module "gke" {
  source = "./modules/gke"
  project_id = var.project_id
  region     = var.region
  cluster_name = var.cluster_name
}
