# Universal DevSecOps Pipeline Toolkit

A reusable, stack-agnostic CI/CD pipeline that any project can plug into, with built-in security scanning, staged environments, and safe rollout/rollback — supporting both Docker and Kubernetes deploy targets.

## 🎯 One-Line Pitch

**Build once, deploy everywhere.** A single pipeline toolkit that provides enterprise-grade DevSecOps capabilities for personal projects, with automatic security scanning, environment promotion, and dual deployment targets (Docker + Kubernetes).

## 🏗️ Architecture

```
                    ┌─────────────────────┐
                    │   pipeline-toolkit    │   ← standalone repo
                    │  (reusable workflow)  │
                    └──────────┬───────────┘
                               │ called via workflow_call
        ┌──────────────────────┼──────────────────────┐
        │                      │                       │
  ┌─────▼─────┐         ┌──────▼─────┐          ┌──────▼──────┐
  │ POS System │         │   Burger    │          │ ClimbingTribe│
  │  (Node)    │         │   (Node)    │          │   (Node)     │
  └────────────┘         └─────────────┘          └──────────────┘
```

Each project repo has a tiny `pipeline.yml` config and a one-line workflow that calls the shared toolkit. All the real logic lives in one place — you maintain it once, every project benefits.

## ✨ Features

### Core Capabilities
- **Stack-Agnostic**: Auto-detects Node.js, Python, and extensible to other frameworks
- **Dual Deployment Targets**: Docker (VPS) and Kubernetes with simple config switch
- **Security-First**: Parallel scanning for dependencies (Trivy), secrets (Gitleaks), and container vulnerabilities
- **Environment Promotion**: Automatic staging → production with manual approval gates
- **Safe Rollouts**: Health check-based automatic rollback for both Docker and Kubernetes
- **Reusable Workflow**: Single pipeline maintained once, used across multiple projects

### Advanced Features
- **Canary Deployments**: 10% → 100% gradual rollout with health checks
- **SARIF Integration**: Security reports appear in GitHub Security tab
- **Multi-Stage Docker Builds**: Optimized container images with minimal attack surface
- **Generic Helm Chart**: Reusable Kubernetes deployment templates
- **GitHub Environments**: Built-in approval workflow and environment protection

## 🚀 Quick Start

### For New Projects

1. **Add workflow to your project** (`.github/workflows/ci.yml`):
```yaml
on: [push, pull_request]
jobs:
  pipeline:
    uses: your-username/pipeline-toolkit/.github/workflows/pipeline.yml@main
    with:
      deploy_target: docker    # or 'k8s'
      severity_gate: HIGH
    secrets: inherit
```

2. **Add pipeline config** (`pipeline.yml` in your project root):
```yaml
scanners: [trivy, gitleaks]
severity_gate: HIGH
deploy_target: docker
canary: true
```

3. **Push and watch the magic happen**

### For Existing Projects

See [Migration Guide](docs/migration-guide.md) for step-by-step instructions.

## 📋 Pipeline Stages

```
push/PR
   │
   ├──▶ detect-stack        (what language/framework is this?)
   │
   ├──▶ test        ┐
   ├──▶ dep-scan     ├─ run in parallel
   ├──▶ secret-scan  ┘
   │
   ├──▶ build-image        (Docker build, tag with commit SHA)
   ├──▶ image-scan         (Trivy on the built image)
   │
   ├──▶ [branch = develop] ──▶ deploy-staging ──▶ smoke-test
   │
   └──▶ [branch = main] ──▶ manual approval gate ──▶ deploy-prod
                                                          │
                                                          ├─ canary (10%) ──▶ health check
                                                          │        │
                                                          │      pass → full rollout
                                                          │      fail → auto-rollback
```

## 🔧 Supported Stacks

- **Node.js** (auto-detected via `package.json`)
- **Python** (auto-detected via `requirements.txt` or `pyproject.toml`)
- **Extensible**: Add detection logic for any stack

## 🐳 Docker Deployment

### Prerequisites
- Docker and Docker Compose installed on target VPS
- SSH access to VPS
- GitHub Container Registry access

### Configuration
Set `deploy_target: docker` in your pipeline config. The pipeline will:
1. Build and push Docker image to GHCR
2. SSH into your VPS
3. Pull new image and restart containers
4. Run health checks with automatic rollback

## ☸️ Kubernetes Deployment

### Prerequisites
- Kubernetes cluster (k3s, kind, or cloud provider)
- kubectl and Helm installed
- Kubeconfig configured

### Configuration
Set `deploy_target: k8s` in your pipeline config. The pipeline will:
1. Build and push Docker image to GHCR
2. Deploy using generic Helm chart
3. Configure canary rollout if enabled
4. Run health checks with Helm rollback on failure

### Local Development
```bash
# Setup local k3s cluster
./scripts/k8s-setup.sh local

# Deploy to local cluster
helm upgrade --install app ./chart --set image.tag=dev
```

## 🔒 Security Features

### Parallel Scanning
- **Trivy**: Dependency and container vulnerability scanning
- **Gitleaks**: Secret scanning in code and commit history
- **Custom scanners**: Extensible framework for additional security tools

### Severity Gating
Configure acceptable vulnerability severity levels:
- `CRITICAL` - Only block on critical vulnerabilities
- `HIGH` - Block on high and critical (default)
- `MEDIUM` - Block on medium and above
- `LOW` - Block on all vulnerabilities

### SARIF Reports
Security scan results automatically appear in GitHub Security tab for tracking and trending.

## 🌍 Environments

### Staging (automatic)
- Triggered on pushes to `develop` branch
- No approval required
- Fast feedback loop
- Deployed to staging namespace/stack

### Production (manual approval)
- Triggered on pushes to `main` branch
- Requires manual approval in GitHub UI
- Configurable required reviewers
- Deployed to production namespace/stack

## 🔄 Rollback Strategy

### Docker Rollback
- Previous image tag stored on server
- Automatic rollback on health check failure
- Manual rollback via SSH script

### Kubernetes Rollback
- Helm maintains release history automatically
- One-command rollback: `helm rollback app`
- Automatic rollback on health check failure
- Rollback to previous stable release

## 📊 Monitoring & Observability

### Status Dashboard
Generate a status dashboard showing:
- Last deployment time per project
- Deployment success/failure status
- Security scan results
- Environment health

### Metrics Collection
- Prometheus + Grafana integration (optional)
- Basic application metrics
- Kubernetes cluster metrics
- Custom metric support

## 🛠️ Local Development

### Prerequisites
- Docker
- k3s or kind (for K8s development)
- Node.js 18+ or Python 3.8+ (depending on stack)

### Setup
```bash
# Clone the toolkit
git clone https://github.com/your-username/pipeline-toolkit.git
cd pipeline-toolkit

# Setup local development environment
docker compose up -d              # Start local Docker environment
./scripts/k8s-setup.sh local     # Setup local k3s cluster

# Test pipeline locally
act push                         # Run GitHub Actions locally
```

## 📚 Documentation

- [Setup Guide](docs/setup-guide.md) - Complete installation and configuration
- [Configuration Reference](docs/configuration.md) - All available options
- [Migration Guide](docs/migration-guide.md) - Migrating existing projects
- [Troubleshooting](docs/troubleshooting.md) - Common issues and solutions
- [Architecture Deep Dive](docs/architecture.md) - Technical details

## 🎓 Adopted By

- [POS System](https://github.com/your-username/pos-system) - Node.js point-of-sale system
- [Burger](https://github.com/your-username/burger) - Node.js food ordering app  
- [ClimbingTribe](https://github.com/your-username/climbing-tribe) - Node.js climbing community platform

## 🤝 Contributing

Contributions are welcome! Please see [Contributing Guidelines](docs/contributing.md) for details.

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

## 🎯 Resume Line

> *"Designed and built a reusable, stack-agnostic DevSecOps pipeline (GitHub Actions) supporting Docker and Kubernetes deployment targets with staged environments, automated vulnerability/secret gating, canary rollouts, and health-check-triggered rollback — adopted across 3 personal full-stack projects."*

## 🔗 Links

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Trivy Security Scanner](https://github.com/aquasecurity/trivy)
- [Gitleaks Secret Scanner](https://github.com/gitleaks/gitleaks)
- [Helm Package Manager](https://helm.sh/)
- [Docker Documentation](https://docs.docker.com/)

---

**Built with ❤️ for developers who want enterprise-grade DevSecOps without the enterprise complexity.**
