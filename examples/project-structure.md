# Example Project Structure

This document shows how a typical project should be structured to work with the Universal DevSecOps Pipeline Toolkit.

## Minimal Project Structure

```
your-project/
├── .github/
│   └── workflows/
│       └── ci.yml              # GitHub Actions workflow calling the pipeline
├── Dockerfile                  # Multi-stage Dockerfile
├── pipeline.yml                # Pipeline configuration (optional)
├── package.json                # For Node.js projects
├── src/                        # Application source code
└── README.md
```

## Complete Project Structure

```
your-project/
├── .github/
│   └── workflows/
│       └── ci.yml              # GitHub Actions workflow
├── src/                        # Application source code
│   ├── index.js
│   ├── routes/
│   └── utils/
├── tests/                      # Test files
│   ├── unit/
│   └── integration/
├── Dockerfile                  # Multi-stage Dockerfile
├── docker-compose.yml          # Local development
├── docker-compose.prod.yml     # Production override
├── pipeline.yml                # Pipeline configuration
├── package.json                # Node.js dependencies
├── .env.example                # Environment variables template
├── .gitleaks.toml              # Gitleaks configuration (optional)
├── .trivy.yaml                 # Trivy configuration (optional)
└── README.md
```

## Required Files

### 1. GitHub Actions Workflow (`.github/workflows/ci.yml`)

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  pipeline:
    uses: your-username/pipeline-toolkit/.github/workflows/pipeline.yml@main
    with:
      deploy_target: 'docker'
      severity_gate: 'HIGH'
      enable_sarif: true
    secrets:
      github_token: ${{ secrets.GITHUB_TOKEN }}
      ssh_host: ${{ secrets.SSH_HOST }}
      ssh_username: ${{ secrets.SSH_USERNAME }}
      ssh_key: ${{ secrets.SSH_KEY }}
```

### 2. Dockerfile

See `Dockerfile.example` in the pipeline-toolkit repository for a template.

### 3. Package.json (Node.js)

Must include test scripts:

```json
{
  "scripts": {
    "test": "jest",
    "test:coverage": "jest --coverage",
    "lint": "eslint src/",
    "build": "webpack --mode production"
  }
}
```

## Optional Files

### Pipeline Configuration (`pipeline.yml`)

Provides project-specific overrides:

```yaml
scanners: [trivy, gitleaks]
severity_gate: HIGH
deploy_target: docker
canary: false
```

### Docker Compose Files

For local development and different deployment environments.

### Security Scanner Configurations

- `.gitleaks.toml` - Custom Gitleaks rules
- `.trivy.yaml` - Trivy scanning configuration

## Integration Steps

1. **Copy the workflow template** from the examples directory
2. **Add required secrets** to your GitHub repository:
   - `SSH_HOST`, `SSH_USERNAME`, `SSH_KEY` (for Docker)
   - `KUBE_CONFIG` (for Kubernetes)
3. **Create a Dockerfile** based on the example
4. **Ensure tests are configured** and passing locally
5. **Push to `develop`** for automatic staging deployment
6. **Push to `main`** for production deployment (requires approval)

## Multiple Projects

You can use the same pipeline toolkit across multiple projects:

```
github.com/your-username/
├── pipeline-toolkit/           # The reusable pipeline
├── pos-system/                 # Project 1 (uses pipeline-toolkit)
├── burger-app/                 # Project 2 (uses pipeline-toolkit)
└── climbing-tribe/             # Project 3 (uses pipeline-toolkit)
```

Each project only needs a simple workflow file and configuration, while all the complex logic lives in the pipeline-toolkit repository.
