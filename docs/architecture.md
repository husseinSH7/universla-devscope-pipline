# Architecture Deep Dive

This document provides a comprehensive technical overview of the Universal DevSecOps Pipeline Toolkit architecture.

## System Architecture

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

## Component Architecture

### 1. GitHub Actions Workflow Layer

#### Main Workflow (`pipeline.yml`)
- **Entry Point**: Reusable workflow called via `workflow_call`
- **Orchestration**: Coordinates all pipeline stages
- **Extensibility**: Configurable inputs and secrets
- **Environment Awareness**: Branch-based deployment logic

#### Composite Actions
- **Docker Deploy Action**: Handles SSH-based Docker deployments
- **K8s Deploy Action**: Manages Helm-based Kubernetes deployments

### 2. Detection Layer

#### Stack Detection Job
```yaml
detect:
  runs-on: ubuntu-latest
  outputs:
    stack: node/python/go/rust/unknown
    package_manager: npm/yarn/pnpm/pip/poetry/go/cargo
    test_command: appropriate test command
```

**Detection Logic**:
- File system inspection (`package.json`, `requirements.txt`, etc.)
- Package manager detection (lock files)
- Test command inference
- Extensible for additional stacks

### 3. Security Layer

#### Parallel Security Scanning
```yaml
test + dependency-scan + secret-scan
  └── run in parallel for speed
```

**Security Components**:
- **Trivy**: Dependency and container vulnerability scanning
- **Gitleaks**: Secret and credential scanning
- **SARIF Integration**: GitHub Security tab reporting
- **Severity Gating**: Configurable vulnerability thresholds

### 4. Build Layer

#### Docker Build Process
```yaml
build:
  - Setup Buildx for advanced builds
  - Login to GHCR
  - Extract metadata (tags, labels)
  - Multi-stage build with caching
  - Push to registry
```

**Build Features**:
- Multi-stage Docker builds
- Layer caching for speed
- Metadata tagging (commit SHA, branch, etc.)
- GitHub Container Registry integration
- Build args for dynamic configuration

### 5. Deployment Layer

#### Dual Deployment Architecture

**Docker Deployment Path**:
```
GitHub Actions → SSH Action → VPS → Docker Compose → Container Update
```

**Kubernetes Deployment Path**:
```
GitHub Actions → K8s Action → Helm → Kubernetes Cluster → Resource Update
```

#### Deployment Abstraction
Both deployment targets use the same interface:
- Image tag parameter
- Environment parameter
- Health check integration
- Rollback capability

### 6. Environment Management

#### GitHub Environments
- **Staging**: Automatic deployment on `develop` branch
- **Production**: Manual approval required on `main` branch
- **Environment Secrets**: Isolated configuration per environment
- **Protection Rules**: Branch protection and required reviewers

#### Environment Configuration
- **Staging**: Single replica, debug logging, relaxed constraints
- **Production**: Multiple replicas, strict logging, resource limits
- **Canary**: Special configuration for gradual rollouts

### 7. Health Check Layer

#### Health Check Integration
```yaml
health-check:
  - Initial delay (startup time)
  - Interval (check frequency)
  - Timeout (response deadline)
  - Retry threshold (failure tolerance)
```

**Health Check Flow**:
1. Deploy new version
2. Wait initial delay
3. Check health endpoint
4. On success: mark deployment successful
5. On failure: trigger automatic rollback

### 8. Rollback Layer

#### Rollback Strategies

**Docker Rollback**:
- Previous image tag stored on server
- Docker Compose file update
- Container restart with previous image
- Tag reference management

**Kubernetes Rollback**:
- Helm release history management
- One-command rollback: `helm rollback`
- Automatic history tracking
- Revision-based rollback

### 9. Canary Deployment Layer

#### Canary Architecture
```yaml
canary:
  enabled: true
  percentage: 10%
```

**Canary Process**:
1. Deploy canary with N% traffic
2. Monitor canary performance
3. Gradually increase traffic
4. Complete canary at 100%
5. Rollback on failure detection

**Implementation**:
- Kubernetes: Rolling update strategy
- Ingress annotations for traffic splitting
- Separate canary values file
- Monitoring integration

## Data Flow

### Pipeline Execution Flow

```
1. Push/PR Trigger
   ↓
2. Stack Detection
   ↓
3. Parallel Execution
   ├─→ Tests
   ├─→ Dependency Scan
   └─→ Secret Scan
   ↓
4. Docker Build & Push
   ↓
5. Image Scan
   ↓
6. Branch Evaluation
   ├─→ develop: Staging Deployment
   └─→ main: Production Deployment (with approval)
   ↓
7. Health Check
   ↓
8. Success OR Rollback
```

### Configuration Flow

```
Project Config (pipeline.yml)
   ↓
GitHub Workflow Inputs
   ↓
Action Parameters
   ↓
Deployment Configuration
   ↓
Infrastructure Changes
```

## Security Architecture

### Security Layers

1. **Code Security**
   - Secret scanning (Gitleaks)
   - Dependency vulnerability scanning (Trivy)
   - SARIF reporting to GitHub Security

2. **Container Security**
   - Multi-stage builds (minimal attack surface)
   - Image vulnerability scanning
   - Non-root user execution
   - Read-only filesystem where possible

3. **Infrastructure Security**
   - SSH key authentication
   - RBAC for Kubernetes
   - Network policies
   - Pod security policies

4. **Pipeline Security**
   - GitHub Secrets for sensitive data
   - Environment-specific secrets
   - Approval gates for production
   - Audit trail via GitHub Actions logs

## Scalability Architecture

### Horizontal Scaling

**Kubernetes HPA**:
- CPU-based autoscaling
- Memory-based autoscaling
- Custom metrics support
- Configurable min/max replicas

**Docker Swarm** (optional):
- Service scaling
- Load balancing
- Rolling updates

### Vertical Scaling

**Resource Management**:
- CPU limits and requests
- Memory limits and requests
- Resource quotas per namespace
- Pod priority and preemption

## Reliability Architecture

### High Availability

**Kubernetes**:
- Multiple replicas
- Pod disruption budgets
- Anti-affinity rules
- Cluster distribution

**Docker**:
- Container restart policies
- Health checks
- Load balancing (optional)

### Failure Recovery

**Automatic Rollback**:
- Health check failure detection
- Automatic trigger
- Previous version restoration
- Rollback verification

**Manual Recovery**:
- Rollback scripts
- History tracking
- Manual intervention points

## Observability Architecture

### Monitoring

**Application Monitoring**:
- Health check endpoints
- Application metrics
- Performance monitoring
- Error tracking

**Infrastructure Monitoring**:
- Kubernetes metrics (Prometheus)
- Docker metrics
- Resource utilization
- Network monitoring

### Logging

**Structured Logging**:
- JSON log format
- Log aggregation
- Centralized logging
- Log retention policies

### Alerting

**Alert Channels**:
- Slack notifications
- Email alerts
- Custom webhooks
- GitHub status checks

## Extension Points

### Adding New Stacks

**Detection Logic**:
```yaml
- Add file detection in detect job
- Add package manager detection
- Define test command
- Add setup steps
```

### Adding New Security Scanners

**Scanner Integration**:
```yaml
- Add parallel job
- Configure SARIF output
- Add to workflow
- Update documentation
```

### Adding New Deployment Targets

**Target Integration**:
```yaml
- Create composite action
- Add deployment logic
- Integrate with workflow
- Add rollback support
```

## Performance Optimization

### Pipeline Performance

**Parallel Execution**:
- Independent jobs run concurrently
- Dependency management
- Resource optimization

**Caching Strategies**:
- Docker layer caching
- Dependency caching
- Build artifact caching

### Deployment Performance

**Rolling Updates**:
- Zero-downtime deployments
- Progressive rollout
- Health check integration

**Resource Optimization**:
- Right-sizing containers
- Resource limits
- Efficient base images

## Compliance and Governance

### Audit Trail

**GitHub Actions Logs**:
- Complete execution history
- Step-by-step tracking
- Secret usage tracking
- Approval records

**Change Management**:
- Git-based configuration
- Version control
- Change documentation
- Approval workflows

### Policy Enforcement

**Branch Protection**:
- Required status checks
- PR requirements
- Code owner approval

**Environment Protection**:
- Required reviewers
- Wait timers
- Environment-specific rules

## Technology Stack

### Core Technologies
- **GitHub Actions**: Workflow orchestration
- **Docker**: Containerization
- **Kubernetes**: Container orchestration
- **Helm**: Package management
- **Trivy**: Security scanning
- **Gitleaks**: Secret scanning

### Supporting Technologies
- **kind/k3s**: Local development
- **nginx**: Ingress controller
- **Prometheus/Grafana**: Monitoring (optional)
- **cert-manager**: TLS management (optional)

## Best Practices Implementation

### DevSecOps Best Practices
- Security as code
- Infrastructure as code
- Automated testing
- Continuous monitoring
- Rapid rollback capability

### GitOps Best Practices
- Single source of truth
- Declarative configuration
- Automated synchronization
- Drift detection

### Cloud-Native Best Practices
- Microservices architecture
- Container orchestration
- Immutable infrastructure
- Service discovery

This architecture provides a solid foundation for enterprise-grade DevSecOps practices while maintaining simplicity and ease of use for personal projects.
