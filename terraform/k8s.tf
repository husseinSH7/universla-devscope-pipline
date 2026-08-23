# Kubernetes cluster configuration

resource "digitalocean_kubernetes_cluster" "k8s_cluster" {
  name    = "${var.project_name}-k8s"
  region  = var.region
  version = "1.28.0-do.0"
  
  node_pool {
    name       = "worker-pool"
    size       = var.k8s_node_size
    node_count = var.k8s_node_count
    
    tags = ["devsecops", "kubernetes", "pipeline-toolkit"]
    
    taint {
      key    = "workload"
      value  = "general"
      effect = "NoSchedule"
    }
  }
  
  tags = ["devsecops", "kubernetes", "pipeline-toolkit"]
}

# Kubernetes DNS records
resource "digitalocean_record" "k8s_api_a" {
  domain = data.digitalocean_domain.default.name
  name   = "k8s-api"
  type   = "A"
  value  = digitalocean_kubernetes_cluster.k8s_cluster.ipv4_address
}

resource "digitalocean_record" "k8s_wildcard_cname" {
  domain = data.digitalocean_domain.default.name
  name   = "*.k8s"
  type   = "CNAME"
  value  = "k8s-api.${data.digitalocean_domain.default.name}"
}
