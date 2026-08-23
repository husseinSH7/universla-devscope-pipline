# Contributing Guide

Thank you for your interest in contributing to the Universal DevSecOps Pipeline Toolkit! This document provides guidelines and instructions for contributors.

## Code of Conduct

Please be respectful and constructive in all interactions. We aim to create a welcoming community for all contributors.

## How to Contribute

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When creating a bug report, include:

- **Description**: Clear description of the problem
- **Reproduction Steps**: Steps to reproduce the issue
- **Expected Behavior**: What you expected to happen
- **Actual Behavior**: What actually happened
- **Environment**: 
  - OS and version
  - Docker/Kubernetes versions
  - Helm version
  - Any relevant configuration

### Suggesting Enhancements

Enhancement suggestions are welcome! Please provide:

- **Description**: Clear description of the enhancement
- **Motivation**: Why this enhancement would be useful
- **Proposed Solution**: How you envision the enhancement working
- **Alternatives**: Any alternative solutions you've considered

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Make your changes** following the coding standards
3. **Add tests** if applicable
4. **Update documentation** for any changes
5. **Ensure all tests pass**
6. **Submit a pull request** with a clear description

## Development Setup

### Prerequisites

- Git
- Docker
- kubectl and Helm (for Kubernetes development)
- Make (optional, for using Makefile)

### Local Development

```bash
# Clone your fork
git clone https://github.com/your-username/pipeline-toolkit.git
cd pipeline-toolkit

# Create a feature branch
git checkout -b feature/your-feature-name

# Make your changes
# ...

# Test changes locally
# Test Docker workflows
docker-compose -f docker-compose.yml config

# Test Helm charts
helm lint ./chart
helm template test ./chart

# Validate YAML files
yamllint .github/workflows/
```

### Testing

#### Testing GitHub Actions Workflows

Use [act](https://github.com/nektos/act) to test GitHub Actions locally:

```bash
# Install act
brew install act  # macOS
# or download from https://github.com/nektos/act

# Test workflow
act push
```

#### Testing Helm Charts

```bash
# Lint chart
helm lint ./chart

# Test template rendering
helm template test ./chart --values chart/values.yaml

# Install chart to local cluster for testing
helm install test ./chart --values chart/values-staging.yaml

# Test upgrade
helm upgrade test ./chart --values chart/values-production.yaml

# Cleanup
helm uninstall test
```

#### Testing Docker Configurations

```bash
# Validate Docker Compose files
docker-compose -f docker-compose.yml config
docker-compose -f docker-compose.staging.yml config
docker-compose -f docker-compose.production.yml config

# Test build
docker build -f Dockerfile.example -t test-app .

# Test local deployment
docker-compose up -d
docker-compose logs -f
docker-compose down
```

## Coding Standards

### YAML Files

- Use 2 spaces for indentation (not tabs)
- Use consistent quoting
- Add comments for complex configurations
- Sort keys alphabetically when appropriate
- Keep lines under 100 characters when possible

### Shell Scripts

- Use `set -e` for error handling
- Use `#!/bin/bash` shebang
- Add comments for complex logic
- Use meaningful variable names
- Handle errors gracefully
- Provide usage information

### Helm Charts

- Follow Helm best practices
- Use meaningful names and labels
- Add descriptions for values
- Include resource limits
- Implement health checks
- Use proper RBAC

### Documentation

- Use clear, concise language
- Include code examples
- Update table of contents when needed
- Keep documentation up to date with code changes
- Use proper formatting (markdown, code blocks, etc.)

## Project Structure

```
pipeline-toolkit/
├── .github/
│   ├── workflows/
│   │   └── pipeline.yml          # Main reusable workflow
│   └── actions/
│       ├── docker-deploy/        # Docker deployment action
│       └── k8s-deploy/           # Kubernetes deployment action
├── chart/                        # Helm chart
│   ├── Chart.yaml
│   ├── values.yaml
│   ├── values-staging.yaml
│   ├── values-production.yaml
│   ├── values-canary.yaml
│   └── templates/
├── scripts/                      # Utility scripts
├── docs/                         # Documentation
├── examples/                     # Example configurations
├── docker-compose.yml            # Docker configurations
└── README.md
```

## Commit Messages

Follow conventional commit format:

```
type(scope): subject

body

footer
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Test changes
- `chore`: Maintenance tasks

Examples:
- `feat(k8s): add pod disruption budget support`
- `fix(docker): resolve SSH connection timeout issue`
- `docs(readme): update quick start instructions`
- `test(helm): add validation tests for chart templates`

## Release Process

Releases are managed through GitHub Releases:

1. Update version in `chart/Chart.yaml`
2. Update CHANGELOG.md
3. Create a new release on GitHub
4. Tag the release with version number
5. Update documentation if needed

## Documentation Standards

### README.md
- Clear project description
- Quick start guide
- Installation instructions
- Basic usage examples
- Links to detailed documentation

### Documentation Files
- Use proper markdown formatting
- Include code examples
- Add diagrams where helpful
- Keep content up to date
- Use consistent terminology

### Code Comments
- Comment complex logic
- Explain non-obvious implementations
- Keep comments concise and relevant
- Update comments when code changes

## Issue Triage

Issues are labeled and prioritized:

- `bug`: Bug reports
- `enhancement`: Feature requests
- `documentation`: Documentation issues
- `good first issue`: Good for new contributors
- `help wanted`: Community help needed
- `priority: high`, `priority: medium`, `priority: low`: Priority levels

## Getting Help

- Check existing documentation
- Search existing issues and discussions
- Ask questions in GitHub Discussions
- Join our community chat (if available)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Recognition

Contributors are recognized in:
- CONTRIBUTORS.md file
- Release notes
- GitHub contributors list

Thank you for contributing to the Universal DevSecOps Pipeline Toolkit!
