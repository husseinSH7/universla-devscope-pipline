# Setup Guide

This guide will help you set up the Universal DevSecOps Pipeline Toolkit for your projects.

## Prerequisites

### For All Users
- GitHub account with GitHub Actions enabled
- Basic understanding of Git and CI/CD concepts

### For Docker Deployment
- Docker and Docker Compose installed on target VPS
- SSH access to VPS
- GitHub Container Registry access

### For Kubernetes Deployment
- Kubernetes cluster (k3s, kind, or cloud provider)
- kubectl and Helm installed locally
- Kubeconfig configured

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/pipeline-toolkit.git
cd pipeline-toolkit
```

### 2. Make Scripts Executable

```bash
chmod +x scripts/*.sh
```

### 3. Set Up GitHub Repository

1. Create a new GitHub repository for the pipeline toolkit
2. Push the code to GitHub
3. Configure repository settings:
   - Enable GitHub Actions
   - Set up branch protection rules for `main`
   - Configure environments (staging, production)

### 4. Configure GitHub Secrets

For Docker deployment:
- `SSH_HOST`: Your VPS hostname/IP
- `SSH_USERNAME`: SSH username for VPS
- `SSH_KEY`: Private SSH key for VPS access

For Kubernetes deployment:
- `KUBE_CONFIG`: Base64-encoded kubeconfig file

### 5. Test the Pipeline

Create a test project and use one of the example workflows:

```bash
# Copy example workflow
cp examples/workflow-nodejs.yml ../your-project/.github/workflows/ci.yml

# Push to test
cd ../your-project
git add .github/workflows/ci.yml
git commit -m "Add pipeline workflow"
git push origin develop
```

## Kubernetes Local Development

### Setup Local Cluster

```bash
# Using kind (recommended for local development)
./scripts/k8s-setup.sh kind

# Using k3s (lightweight alternative)
./scripts/k8s-setup.sh k3s
```

### Install Development Tools

```bash
./scripts/k8s-install-tools.sh
```

### Setup Local Registry (Optional)

```bash
./scripts/k8s-local-registry.sh
```

### Deploy Test Application

```bash
# Using Helm
helm upgrade --install app ./chart --set image.tag=dev

# Check deployment
kubectl get pods
kubectl get svc
```

## Docker Local Development

### Build and Test Locally

```bash
# Build Docker image
docker build -t test-app .

# Test with Docker Compose
docker-compose up -d

# Check logs
docker-compose logs -f

# Stop containers
docker-compose down
```

## Project Integration

### For New Projects

1. Copy the example workflow to your project:
```bash
mkdir -p .github/workflows
cp pipeline-toolkit/examples/workflow-nodejs.yml .github/workflows/ci.yml
```

2. Create a Dockerfile based on the example:
```bash
cp pipeline-toolkit/Dockerfile.example Dockerfile
```

3. Add required GitHub secrets to your project repository

4. Push to `develop` branch for automatic staging deployment

### For Existing Projects

1. Add the workflow file to `.github/workflows/`
2. Create or update your Dockerfile
3. Configure GitHub secrets
4. Test with a pull request first
5. Merge to `develop` for staging deployment

## Configuration

### Pipeline Configuration

Create a `pipeline.yml` in your project root:

```yaml
scanners: [trivy, gitleaks]
severity_gate: HIGH
deploy_target: docker
canary: false
```

### Environment Variables

Configure environment-specific variables in:
- `chart/values-staging.yaml` (Kubernetes staging)
- `chart/values-production.yaml` (Kubernetes production)
- `docker-compose.staging.yml` (Docker staging)
- `docker-compose.production.yml` (Docker production)

## Troubleshooting

### Common Issues

**Pipeline fails on SSH connection:**
- Verify SSH credentials are correct
- Check VPS firewall allows SSH connections
- Test SSH connection manually

**Kubernetes deployment fails:**
- Verify kubeconfig is valid
- Check cluster connectivity: `kubectl cluster-info`
- Verify Helm chart syntax: `helm lint ./chart`

**Docker build fails:**
- Check Dockerfile syntax
- Verify build context is correct
- Test build locally first

**Security scans fail:**
- Review scan results in GitHub Security tab
- Update dependencies if vulnerabilities found
- Adjust severity gate if appropriate

### Getting Help

- Check the [Troubleshooting Guide](troubleshooting.md)
- Review GitHub Actions logs
- Check script logs in `/var/log/` on VPS
- Use `kubectl logs` for Kubernetes issues

## Next Steps

1. Customize the pipeline for your specific needs
2. Add custom security scanning rules
3. Configure monitoring and alerting
4. Set up status dashboard
5. Document your specific configurations

## Security Best Practices

1. Never commit secrets or keys to the repository
2. Use GitHub Secrets for sensitive data
3. Regularly update dependencies
4. Review and address security scan results
5. Use branch protection rules
6. Require approvals for production deployments
