# Configuration Reference

This document provides detailed configuration options for the Universal DevSecOps Pipeline Toolkit.

## GitHub Actions Workflow Configuration

### Workflow Inputs

The reusable pipeline workflow accepts the following inputs:

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `deploy_target` | string | `docker` | Deployment target: `docker` or `k8s` |
| `severity_gate` | string | `HIGH` | Minimum severity level to block deployment: `CRITICAL`, `HIGH`, `MEDIUM`, `LOW` |
| `enable_canary` | boolean | `false` | Enable canary deployment for Kubernetes |
| `canary_percentage` | string | `10%` | Canary deployment percentage (e.g., `10%`, `25%`) |
| `enable_sarif` | boolean | `true` | Enable SARIF report upload to GitHub Security |
| `dockerfile_path` | string | `./Dockerfile` | Path to Dockerfile |
| `build_context` | string | `.` | Docker build context directory |

### Workflow Secrets

The pipeline requires the following secrets:

#### Common Secrets
- `github_token`: GitHub token for authentication (automatically provided)

#### Docker Deployment Secrets
- `ssh_host`: VPS hostname or IP address
- `ssh_username`: SSH username for VPS access
- `ssh_key`: Private SSH key for VPS authentication

#### Kubernetes Deployment Secrets
- `kube_config`: Base64-encoded kubeconfig file

## Pipeline Configuration File

Create a `pipeline.yml` file in your project root to override default settings:

```yaml
# Security scanning configuration
scanners:
  - trivy          # Dependency and container vulnerability scanning
  - gitleaks       # Secret scanning

# Minimum severity level to block deployment
severity_gate: HIGH

# Deployment target: docker or k8s
deploy_target: docker

# Canary deployment configuration (for k8s only)
canary:
  enabled: false
  percentage: 10%

# Docker configuration
docker:
  build_context: .
  dockerfile_path: ./Dockerfile
  image_name: ghcr.io/your-username/your-repo

# Kubernetes configuration
kubernetes:
  chart_path: ./chart
  release_name: app
  namespace: default
  create_namespace: true

# Environment-specific settings
environments:
  staging:
    branch: develop
    auto_deploy: true
    replicas: 1
  
  production:
    branch: main
    auto_deploy: false
    replicas: 3
    enable_canary: true

# Health check configuration
health_check:
  enabled: true
  path: /health
  timeout: 30
  retries: 3

# Notification settings (optional)
notifications:
  slack:
    enabled: false
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
  email:
    enabled: false
    recipients:
      - devops@example.com
```

## Helm Chart Configuration

### Default Values (`values.yaml`)

```yaml
# Replica configuration
replicaCount: 2

# Image configuration
image:
  repository: ghcr.io/your-username/your-repo
  pullPolicy: IfNotPresent
  tag: "latest"

# Service account configuration
serviceAccount:
  create: true
  annotations: {}
  name: ""

# Pod security context
podSecurityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000

# Container security context
securityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities:
    drop:
      - ALL

# Service configuration
service:
  type: ClusterIP
  port: 80
  targetPort: 3000
  annotations: {}

# Ingress configuration
ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  hosts:
    - host: chart-example.local
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: chart-example-tls
      hosts:
        - chart-example.local

# Resource limits and requests
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

# Autoscaling configuration
autoscaling:
  enabled: false
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
  targetMemoryUtilizationPercentage: 80

# Node selector, tolerations, and affinity
nodeSelector: {}
tolerations: []
affinity: {}

# Environment-specific configuration
environment: production

# Canary deployment configuration
canary:
  enabled: false
  percentage: 10%

# Health check configuration
healthCheck:
  enabled: true
  path: /health
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3
  successThreshold: 1

# Application environment variables
app:
  env: []
  envFrom: []
  secrets: []
  configMaps: []

# Probe configurations
livenessProbe:
  enabled: true
  httpGet:
    path: /health
    port: http
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3

readinessProbe:
  enabled: true
  httpGet:
    path: /ready
    port: http
  initialDelaySeconds: 10
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 3

# Volume mounts
volumes: []
volumeMounts: []

# Pod disruption budget
podDisruptionBudget:
  enabled: true
  minAvailable: 1

# Service monitor for Prometheus
serviceMonitor:
  enabled: false
  interval: 30s
  scrapeTimeout: 10s
  labels: {}
```

### Environment-Specific Values

#### Staging (`values-staging.yaml`)
- Single replica for cost savings
- Debug logging enabled
- Relaxed health checks
- No TLS/SSL requirements
- Development-friendly configuration

#### Production (`values-production.yaml`)
- Multiple replicas for high availability
- Production logging levels
- Strict health checks
- TLS/SSL enabled
- Resource limits and autoscaling
- Pod disruption budget enabled

#### Canary (`values-canary.yaml`)
- Canary-specific ingress annotations
- Reduced resource allocation
- Frequent health checks
- Monitoring enabled
- Canary environment variables

## Docker Compose Configuration

### Local Development (`docker-compose.yml`)
- Volume mounts for hot reloading
- Development environment variables
- Debug logging
- Service dependencies (postgres, redis)
- Administrative tools

### Staging (`docker-compose.staging.yml`)
- Single replica deployment
- Staging environment configuration
- Basic monitoring
- Development-friendly resource limits

### Production (`docker-compose.production.yml`)
- Multiple replicas if using swarm
- Production environment variables
- Resource limits
- Optimized configuration
- Logging and monitoring

## Security Scanner Configuration

### Trivy Configuration

Create a `.trivy.yaml` file for custom Trivy settings:

```yaml
# Trivy configuration
severity:
  - CRITICAL
  - HIGH
  - MEDIUM

vulnerability:
  detected-severity: CRITICAL
  ignore-unfixed: false

format: sarif
output: trivy-results.sarif

# Custom rules
skip-dirs:
  - vendor/
  - node_modules/

skip-files:
  - "**/*.test.js"
```

### Gitleaks Configuration

Create a `.gitleaks.toml` file for custom Gitleaks rules:

```toml
# Gitleaks configuration
title = "Gitleaks Custom Configuration"

[allowlist]
description = "Global Allowlist"

regexes = [
  '''example''',
  '''test''',
  '''localhost'''
]

[[rules]]
description = "AWS Access Key"
regex = '''(A3T[A-Z0-9]|AKIA|AGPA|AIDA|AROA|AIPA|ANPA|ANVA|ASIA)[A-Z0-9]{16}'''
tags = ["key", "AWS"]

[[rules]]
description = "GitHub Token"
regex = '''ghp_[a-zA-Z0-9]{36}'''
tags = ["key", "GitHub"]
```

## GitHub Environment Configuration

### Setting Up Environments

1. Go to repository Settings > Environments
2. Create `staging` environment:
   - No approval required
   - Add environment-specific secrets if needed
3. Create `production` environment:
   - Add required reviewers
   - Add production-specific secrets
   - Configure wait timer if needed

### Environment Protection Rules

- Required reviewers for production
- Branch protection rules
- Deployment timeout settings
- Environment-specific secrets

## Notification Configuration

### Slack Notifications

Configure Slack webhooks for deployment notifications:

```yaml
notifications:
  slack:
    enabled: true
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
    channel: "#deployments"
    username: "Deployment Bot"
    icon_emoji: ":rocket:"
```

### Email Notifications

Configure email notifications for important events:

```yaml
notifications:
  email:
    enabled: true
    recipients:
      - devops@example.com
      - team@example.com
    smtp_server: smtp.example.com
    smtp_port: 587
    smtp_username: ${{ secrets.SMTP_USERNAME }}
    smtp_password: ${{ secrets.SMTP_PASSWORD }}
```

## Advanced Configuration

### Custom Build Arguments

Add custom build arguments to Docker builds:

```yaml
docker:
  build_args:
    - BUILD_DATE=${{ github.event.head_commit.timestamp }}
    - VCS_REF=${{ github.sha }}
    - VERSION=${{ github.ref_name }}
```

### Custom Helm Values

Override Helm values during deployment:

```yaml
kubernetes:
  set_values:
    - name: custom.value
      value: "custom"
  set_string_values:
    - name: custom.string
      value: "string-value"
  set_files:
    - name: custom.file
      value: ./path/to/file
```

### Parallel Execution

Configure parallel job execution:

```yaml
parallel_jobs:
  test: true
  security_scan: true
  build: false
```

## Configuration Validation

### Validate Workflow YAML

```bash
# Using GitHub Actions CLI
act -l

# Using YAML linter
yamllint .github/workflows/pipeline.yml
```

### Validate Helm Chart

```bash
# Lint Helm chart
helm lint ./chart

# Template validation
helm template test ./chart --values chart/values.yaml
```

### Validate Docker Compose

```bash
# Validate Docker Compose configuration
docker-compose config

# Check syntax
docker-compose -f docker-compose.yml config
```

## Best Practices

1. **Use environment-specific configurations** - Separate staging and production settings
2. **Keep secrets out of repository** - Use GitHub Secrets or secret management
3. **Validate configurations** - Test configuration files before deployment
4. **Document custom configurations** - Maintain clear documentation
5. **Use version control** - Track configuration changes
6. **Implement configuration drift detection** - Monitor for unintended changes
7. **Use configuration management** - Consider tools like Ansible or Terraform for infrastructure
8. **Regular audits** - Review and update configurations periodically
