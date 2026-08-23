# Monitoring stack configuration (Prometheus, Grafana)

# Install Prometheus Operator
resource "helm_release" "prometheus_operator" {
  count      = var.enable_monitoring ? 1 : 0
  name       = "prometheus-operator"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  create_namespace = true
  
  set {
    name  = "grafana.adminPassword"
    value = var.grafana_password
  }
  
  set {
    name  = "grafana.ingress.enabled"
    value = "true"
  }
  
  set {
    name  = "grafana.ingress.hosts[0]"
    value = "grafana.${var.domain_name}"
  }
  
  set {
    name  = "prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues"
    value = "false"
  }
}
