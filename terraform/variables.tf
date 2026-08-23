# Variables for Terraform configuration

variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "github_token" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
}

variable "github_owner" {
  description = "GitHub username or organization name"
  type        = string
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig file for Kubernetes cluster"
  type        = string
  default     = "~/.kube/config"
}

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "pipeline-toolkit"
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "nyc1"
}

variable "droplet_size" {
  description = "Size of the Docker VPS droplet"
  type        = string
  default     = "s-2vcpu-4gb"
}

variable "k8s_node_size" {
  description = "Size of Kubernetes cluster nodes"
  type        = string
  default     = "s-2vcpu-4gb"
}

variable "k8s_node_count" {
  description = "Number of nodes in Kubernetes cluster"
  type        = number
  default     = 3
}

variable "domain_name" {
  description = "Domain name for the project"
  type        = string
  default     = "example.com"
}

variable "enable_monitoring" {
  description = "Enable monitoring stack (Prometheus, Grafana)"
  type        = bool
  default     = true
}

variable "grafana_password" {
  description = "Admin password for Grafana"
  type        = string
  sensitive   = true
  default     = "changeme"
}
