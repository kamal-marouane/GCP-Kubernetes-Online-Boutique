output "kubeconfig" {
  description = "Kubeconfig file content"
  value       = module.gke.kubeconfig
}

output "cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = module.gke.endpoint
}