# Outputs from Terraform configuration

output "docker_vps_ip" {
  description = "Public IP address of the Docker VPS"
  value       = digitalocean_droplet.docker_vps.ipv4_address
}

output "docker_vps_name" {
  description = "Name of the Docker VPS"
  value       = digitalocean_droplet.docker_vps.name
}

output "k8s_cluster_endpoint" {
  description = "Kubernetes cluster endpoint"
  value       = digitalocean_kubernetes_cluster.k8s_cluster.endpoint
}

output "k8s_cluster_name" {
  description = "Kubernetes cluster name"
  value       = digitalocean_kubernetes_cluster.k8s_cluster.name
}

output "kubeconfig" {
  description = "Kubeconfig for the Kubernetes cluster"
  value       = digitalocean_kubernetes_cluster.k8s_cluster.kube_config[0].raw_config
  sensitive   = true
}

output "grafana_url" {
  description = "URL of Grafana dashboard"
  value       = var.enable_monitoring ? "https://grafana.${var.domain_name}" : null
}

output "prometheus_url" {
  description = "URL of Prometheus"
  value       = var.enable_monitoring ? "https://prometheus.${var.domain_name}" : null
}

output "github_repo_url" {
  description = "URL of the GitHub repository"
  value       = github_repository.pipeline_toolkit.html_url
}
