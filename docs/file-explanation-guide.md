# Comprehensive File Explanation Guide

This guide explains every file in the Universal DevSecOps Pipeline Toolkit and how they work together to create a complete DevSecOps solution.

## 📁 Root Directory Files

### README.md
**Purpose:** Main project documentation and entry point
**Contents:**
- Project overview and one-line pitch
- Architecture diagram
- Feature list and capabilities
- Quick start guide
- Usage instructions
- Links to detailed documentation
**How it works:** Serves as the primary documentation for users and contributors, providing a high-level understanding of the project and directing users to detailed guides.

### LICENSE
**Purpose:** Legal licensing information
**Contents:** MIT License text
**How it works:** Specifies that the project is open source under MIT License, allowing free use, modification, and distribution.

### .gitignore
**Purpose:** Git configuration for files to exclude from version control
**Contents:** Patterns for OS files, IDE files, secrets, temporary files, build artifacts
**How it works:** Prevents sensitive information (SSH keys, kubeconfigs) and generated files from being committed to the repository.

### universal-devsecops-pipeline-docs.md
**Purpose:** Original design document (reference)
**Contents:** Complete design specification from which the toolkit was built
**How it works:** Serves as historical reference and design rationale for the project architecture.

## 📁 .github/ Directory

### .github/workflows/pipeline.yml
**Purpose:** Main reusable GitHub Actions workflow
**Contents:**
- Workflow trigger configuration (workflow_call)
- Input parameters (deploy_target, severity_gate, enable_canary, etc.)
- Job definitions (detect, test, dependency-scan, secret-scan, build, image-scan, deploy-staging, deploy-production)
- Security scanning configuration
- Docker build and push logic
- Environment-based deployment logic
**How it works:** This is the core of the toolkit. Projects call this workflow via `workflow_call`, providing inputs that customize behavior. The workflow:
1. Detects the application stack
2. Runs tests and security scans in parallel
3. Builds and pushes Docker images
4. Deploys to staging or production based on branch
5. Performs health checks with automatic rollback

### .github/actions/docker-deploy/action.yml
**Purpose:** Composite action for Docker-based deployments
**Contents:**
- SSH key setup and authentication
- Docker Compose file updates
- Image pull and container restart
- Health check integration
- URL output for monitoring
**How it works:** When a project chooses Docker deployment, this action:
1. Sets up SSH authentication to the VPS
2. Updates the Docker Compose file with the new image tag
3. Pulls the new image and restarts containers
4. Performs cleanup of old images
5. Returns the deployment URL for health checks

### .github/actions/k8s-deploy/action.yml
**Purpose:** Composite action for Kubernetes deployments
**Contents:**
- kubectl and Helm setup
- Kubeconfig configuration
- Namespace creation
- Helm deployment with values
- Rollout status verification
**How it works:** When a project chooses Kubernetes deployment, this action:
1. Sets up kubectl and Helm tools
2. Configures Kubernetes authentication
3. Creates namespaces if needed
4. Deploys using Helm with environment-specific values
5. Waits for deployment to be ready
6. Returns the deployment URL for health checks

## 📁 chart/ Directory (Helm Chart)

### chart/Chart.yaml
**Purpose:** Helm chart metadata
**Contents:** Chart name, version, description, maintainers
**How it works:** Defines the Helm chart identity and versioning, used by Helm for chart management and repository indexing.

### chart/values.yaml
**Purpose:** Default Helm chart values
**Contents:**
- Replica count and image configuration
- Service account and security contexts
- Service and ingress configuration
- Resource limits and autoscaling
- Health check and probe settings
- Canary deployment configuration
**How it works:** Provides default configuration for all Kubernetes deployments. These values can be overridden by environment-specific files or during Helm installation.

### chart/values-staging.yaml
**Purpose:** Staging environment-specific values
**Contents:**
- Single replica for cost savings
- Debug logging enabled
- Relaxed health checks
- No TLS requirements
- Development-friendly resource limits
**How it works:** Overrides default values for staging deployments, prioritizing cost savings and developer experience over production-like constraints.

### chart/values-production.yaml
**Purpose:** Production environment-specific values
**Contents:**
- Multiple replicas for high availability
- Production logging levels
- Strict health checks
- TLS/SSL enabled
- Resource limits and autoscaling
- Pod disruption budget enabled
**How it works:** Overrides default values for production deployments, prioritizing reliability, security, and performance.

### chart/values-canary.yaml
**Purpose:** Canary deployment configuration
**Contents:**
- Canary-specific ingress annotations
- Reduced resource allocation
- Frequent health checks
- Monitoring enabled
- Canary environment variables
**How it works:** Provides specialized configuration for canary deployments, allowing gradual traffic rollout with enhanced monitoring.

### chart/templates/_helpers.tpl
**Purpose:** Helm template helper functions
**Contents:**
- Name generation functions
- Label generation functions
- Selector label functions
- Service account name functions
**How it works:** Provides reusable template functions that generate consistent naming and labeling across all Kubernetes resources, ensuring proper resource relationships and discovery.

### chart/templates/deployment.yaml
**Purpose:** Kubernetes Deployment resource
**Contents:**
- Replica count and strategy configuration
- Container image and port configuration
- Liveness and readiness probes
- Resource limits and requests
- Volume mounts and environment variables
**How it works:** Defines the main application deployment, including how many replicas run, which container image to use, how to check if the application is healthy, and what resources it needs.

### chart/templates/service.yaml
**Purpose:** Kubernetes Service resource
**Contents:**
- Service type (ClusterIP)
- Port configuration
- Selector labels
**How it works:** Creates a network endpoint for the application, allowing other services to communicate with it via a stable DNS name.

### chart/templates/ingress.yaml
**Purpose:** Kubernetes Ingress resource
**Contents:**
- Ingress class and annotations
- Host and path routing
- TLS configuration
**How it works:** Configures external access to the application, handling HTTP/HTTPS routing, SSL termination, and domain-based routing.

### chart/templates/serviceaccount.yaml
**Purpose:** Kubernetes ServiceAccount resource
**Contents:**
- Service account name and annotations
**How it works:** Provides an identity for the application's pods, used for Kubernetes RBAC (Role-Based Access Control).

### chart/templates/hpa.yaml
**Purpose:** Horizontal Pod Autoscaler
**Contents:**
- Autoscaling enabled flag
- Min/max replica limits
- CPU and memory utilization targets
**How it works:** Automatically scales the number of replicas based on resource utilization, ensuring the application can handle varying loads.

### chart/templates/configmap.yaml
**Purpose:** Kubernetes ConfigMap resource
**Contents:**
- Configuration data for the application
**How it works:** Stores configuration data as Kubernetes resources, allowing applications to access configuration without hardcoding it in container images.

### chart/templates/secrets.yaml
**Purpose:** Kubernetes Secret resource
**Contents:**
- Sensitive data (passwords, API keys)
**How it works:** Stores sensitive data securely in Kubernetes, making it available to applications while keeping it out of configuration files and container images.

### chart/templates/pdb.yaml
**Purpose:** Pod Disruption Budget
**Contents:**
- Minimum available pods during disruptions
**How it works:** Ensures that a minimum number of pods remain available during voluntary disruptions (like node maintenance), improving application availability.

## 📁 scripts/ Directory

### scripts/health-check.sh
**Purpose:** Application health check script
**Contents:**
- Health endpoint checking logic
- Retry mechanism with configurable attempts
- Success/failure determination
**How it works:** Performs HTTP health checks against the deployed application, with retries and timeout handling. Returns success (exit 0) or failure (exit 1) to trigger rollback logic.

### scripts/docker-rollback.sh
**Purpose:** Docker deployment rollback script
**Contents:**
- SSH authentication setup
- Previous image tag retrieval
- Docker Compose file update
- Container restart with previous image
**How it works:** When a health check fails, this script:
1. Retrieves the previously working image tag
2. Updates Docker Compose to use the previous image
3. Restarts containers with the previous version
4. Cleans up the failed deployment

### scripts/k8s-rollback.sh
**Purpose:** Kubernetes deployment rollback script
**Contents:**
- Helm release history management
- Previous revision identification
- Helm rollback command execution
- Rollout status verification
**How it works:** When a health check fails, this script:
1. Identifies the previous successful Helm revision
2. Executes Helm rollback to that revision
3. Waits for the rollback to complete
4. Verifies the application is healthy

### scripts/k8s-canary-start.sh
**Purpose:** Start canary deployment
**Contents:**
- Canary deployment initialization
- Traffic percentage configuration
- Monitoring setup
**How it works:** Initiates a canary deployment by:
1. Creating a canary deployment with specified traffic percentage
2. Configuring ingress for traffic splitting
3. Setting up enhanced monitoring
4. Providing guidance for completion or rollback

### scripts/k8s-canary-monitor.sh
**Purpose:** Monitor canary deployment
**Contents:**
- Real-time canary status monitoring
- Pod status display
- Resource usage tracking
- Log tailing
**How it works:** Provides real-time visibility into canary deployment health, showing pod status, resource usage, and recent logs to help operators make completion decisions.

### scripts/k8s-canary-complete.sh
**Purpose:** Complete canary deployment
**Contents:**
- Full rollout execution
- Canary disablement
- Traffic routing update
**How it works:** Completes a canary deployment by:
1. Gradually increasing traffic to 100%
2. Disabling canary-specific configuration
3. Switching to standard production configuration
4. Verifying the full rollout is successful

### scripts/k8s-setup.sh
**Purpose:** Kubernetes cluster setup
**Contents:**
- kind/k3s cluster creation
- Cluster configuration
- Network setup
**How it works:** Sets up a local Kubernetes cluster for development and testing, supporting both kind (Docker-based) and k3s (lightweight) clusters.

### scripts/k8s-install-tools.sh
**Purpose:** Install Kubernetes development tools
**Contents:**
- kubectl installation
- Helm installation
- Additional tools (stern, k9s)
**How it works:** Installs all necessary tools for Kubernetes development and operations, ensuring consistent tooling across environments.

### scripts/k8s-delete-cluster.sh
**Purpose:** Delete Kubernetes cluster
**Contents:**
- Cluster deletion logic
- Cleanup procedures
**How it works:** Safely removes Kubernetes clusters created during development, cleaning up resources and preventing conflicts.

### scripts/k8s-local-registry.sh
**Purpose:** Setup local container registry
**Contents:**
- Local registry container creation
- Network configuration
- Kubernetes registry configuration
**How it works:** Creates a local container registry for development, allowing Docker images to be pushed and pulled without requiring remote registry access.

## 📁 terraform/ Directory

### terraform/main.tf
**Purpose:** Terraform main configuration
**Contents:**
- Provider configurations (DigitalOcean, Kubernetes, Helm, GitHub)
- Terraform version requirements
- Provider versions
**How it works:** Defines the Terraform providers used for infrastructure provisioning and their configurations.

### terraform/variables.tf
**Purpose:** Terraform variable definitions
**Contents:**
- Input variables for infrastructure
- Descriptions and default values
- Sensitive variable markers
**How it works:** Defines configurable parameters for infrastructure provisioning, allowing customization without modifying the main Terraform code.

### terraform/outputs.tf
**Purpose:** Terraform output definitions
**Contents:**
- Output values for created resources
- IP addresses, URLs, configuration data
**How it works:** Exports important information from infrastructure provisioning, such as server IPs, cluster endpoints, and access URLs.

### terraform/vps.tf
**Purpose:** Docker VPS provisioning
**Contents:**
- DigitalOcean droplet creation
- Docker installation via user data
- SSH key configuration
- DNS record creation
**How it works:** Provisions a Docker-ready VPS with automatic Docker installation, SSH access, and DNS configuration.

### terraform/k8s.tf
**Purpose:** Kubernetes cluster provisioning
**Contents:**
- DigitalOcean Kubernetes cluster creation
- Node pool configuration
- DNS record creation
**How it works:** Provisions a production-ready Kubernetes cluster with configurable node pools and DNS records.

### terraform/github.tf
**Purpose:** GitHub repository configuration
**Contents:**
- GitHub repository creation
- Branch protection rules
- Environment configuration
- Secret management
**How it works:** Automates GitHub repository setup, including branch protection, environment configuration, and secret management for the pipeline.

### terraform/monitoring.tf
**Purpose:** Monitoring stack deployment
**Contents:**
- Prometheus Operator Helm release
- Grafana configuration
- Ingress setup
**How it works:** Deploys the complete monitoring stack (Prometheus, Grafana) using Helm, with proper ingress and authentication configuration.

### terraform/terraform.tfvars.example
**Purpose:** Example Terraform variables file
**Contents:**
- Sample variable values
- Placeholder tokens
**How it works:** Provides a template for users to create their own `terraform.tfvars` file with actual values for their infrastructure.

## 📁 monitoring/ Directory

### monitoring/prometheus-values.yaml
**Purpose:** Prometheus Operator Helm values
**Contents:**
- Grafana configuration
- Prometheus configuration
- Alertmanager configuration
- Default dashboards
- Component enablement
**How it works:** Configures the complete Prometheus monitoring stack, including Grafana dashboards, Prometheus retention, and alerting rules.

### monitoring/loki-values.yaml
**Purpose:** Loki log aggregation Helm values
**Contents:**
- Loki storage configuration
- Log retention settings
- Promtail configuration
- Log scraping rules
**How it works:** Configures the Loki log aggregation system, including log storage, retention policies, and log collection from Kubernetes pods.

### monitoring/alerting-rules.yaml
**Purpose:** Prometheus alerting rules
**Contents:**
- Deployment alerts
- Security alerts
- Infrastructure alerts
- Application alerts
**How it works:** Defines Prometheus alerting rules for monitoring deployment status, security issues, infrastructure health, and application performance.

### monitoring/grafana-dashboards/deployment-dashboard.json
**Purpose:** Grafana dashboard configuration
**Contents:**
- Dashboard panels and queries
- Visualization settings
- Variable definitions
- Refresh intervals
**How it works:** Defines a comprehensive Grafana dashboard for monitoring deployment status, resource usage, and application performance.

### monitoring/docker-compose-logging.yml
**Purpose:** Docker Compose for log aggregation
**Contents:**
- Loki service definition
- Promtail service definition
- Grafana service definition
- Network and volume configuration
**How it works:** Provides a Docker Compose setup for running the log aggregation stack in Docker environments, mirroring the Kubernetes setup.

### monitoring/loki-config.yml
**Purpose:** Loki server configuration
**Contents:**
- Server settings
- Storage configuration
- Schema configuration
**How it works:** Configures the Loki server for log storage and indexing, defining how logs are stored and queried.

### monitoring/promtail-config.yml
**Purpose:** Promtail log collector configuration
**Contents:**
- Scrape configurations
- Relabeling rules
- Client settings
**How it works:** Configures Promtail to collect logs from various sources (Docker containers, system logs) and send them to Loki.

### monitoring/grafana-datasources.yml
**Purpose:** Grafana datasource configuration
**Contents:**
- Loki datasource definition
- Connection settings
**How it works:** Configures Grafana to use Loki as a datasource for log querying and visualization.

## 📁 dashboard/ Directory

### dashboard/generate-dashboard.sh
**Purpose:** Status dashboard generator script
**Contents:**
- GitHub API integration
- Project status retrieval
- HTML generation
- Dashboard styling
**How it works:** Generates an HTML status dashboard by:
1. Fetching deployment status from GitHub API
2. Collecting security scan results
3. Generating HTML with embedded JavaScript
4. Creating auto-refreshing dashboard

### dashboard/projects.yml
**Purpose:** Projects configuration file
**Contents:**
- Project definitions
- Repository information
- Environment configurations
- Dashboard settings
**How it works:** Defines which projects to monitor on the status dashboard and their specific configurations.

### dashboard/output/index.html
**Purpose:** Generated status dashboard HTML
**Contents:**
- HTML structure
- CSS styling
- JavaScript for data fetching
- Auto-refresh logic
**How it works:** The actual dashboard file that gets generated, providing a real-time view of all projects using the pipeline toolkit.

## 📁 examples/ Directory

### examples/workflow-nodejs.yml
**Purpose:** Example GitHub Actions workflow for Node.js projects
**Contents:**
- Complete workflow configuration
- Docker deployment setup
- Security scanning configuration
**How it works:** Provides a ready-to-use workflow template for Node.js projects, showing how to call the pipeline toolkit with appropriate parameters.

### examples/workflow-k8s.yml
**Purpose:** Example GitHub Actions workflow for Kubernetes projects
**Contents:**
- Kubernetes deployment setup
- Canary deployment configuration
- K8s-specific parameters
**How it works:** Provides a ready-to-use workflow template for projects using Kubernetes deployment, including canary deployment configuration.

### examples/pipeline-config.yml
**Purpose:** Example pipeline configuration file
**Contents:**
- Security scanner configuration
- Deployment target settings
- Environment-specific settings
- Notification configuration
**How it works:** Shows how to configure the pipeline toolkit behavior through a project-level configuration file.

### examples/docker-compose-local.yml
**Purpose:** Example Docker Compose for local development
**Contents:**
- Local development service definitions
- Volume mounts for hot reloading
- Development dependencies
- Administrative tools
**How it works:** Provides a Docker Compose setup for local development, including database, cache, and administrative tools.

### examples/project-structure.md
**Purpose:** Example project structure documentation
**Contents:**
- Minimal project structure
- Complete project structure
- Required files explanation
- Integration steps
**How it works:** Shows how a typical project should be structured to work with the pipeline toolkit, including required and optional files.

## 📁 docs/ Directory

### docs/setup-guide.md
**Purpose:** Complete setup and installation guide
**Contents:**
- Prerequisites
- Installation steps
- Configuration instructions
- Local development setup
- Project integration
**How it works:** Provides step-by-step instructions for setting up the pipeline toolkit, from initial installation to project integration.

### docs/troubleshooting.md
**Purpose:** Troubleshooting guide
**Contents:**
- Common issues and solutions
- GitHub Actions issues
- Docker issues
- Kubernetes issues
- Security scanning issues
**How it works:** Helps users diagnose and fix common problems they might encounter while using the pipeline toolkit.

### docs/configuration.md
**Purpose:** Configuration reference
**Contents:**
- Workflow input parameters
- Pipeline configuration options
- Helm chart values
- Environment variables
- Security scanner configuration
**How it works:** Provides detailed documentation of all configuration options available in the pipeline toolkit.

### docs/architecture.md
**Purpose:** Technical architecture documentation
**Contents:**
- System architecture overview
- Component architecture
- Data flow diagrams
- Security architecture
- Scalability considerations
**How it works:** Provides a deep technical understanding of how the pipeline toolkit works internally, useful for contributors and advanced users.

### docs/contributing.md
**Purpose:** Contribution guidelines
**Contents:**
- Code of conduct
- Development setup
- Testing procedures
- Coding standards
- Release process
**How it works:** Guides contributors on how to participate in the project, ensuring consistent code quality and contribution practices.

### docs/migration-guide.md
**Purpose:** Migration guide for existing projects
**Contents:**
- Assessment phase
- Migration strategies
- Step-by-step process
- Common challenges
- Validation procedures
**How it works:** Helps teams migrate existing projects to use the pipeline toolkit, with strategies for different complexity levels and common challenges.

## 📁 demo/ Directory

### demo/demo-script.md
**Purpose:** Live demonstration script
**Contents:**
- Demo setup instructions
- Step-by-step demo flow
- Speaker notes
- Common issues and solutions
- Demo variations
**How it works:** Provides a structured script for demonstrating the pipeline toolkit, with timing, speaker notes, and contingency plans.

### demo/presentation-outline.md
**Purpose:** Presentation slide outline
**Contents:**
- Slide-by-slide outline
- Key messages
- Visual aids suggestions
- Audience adaptation tips
- Time management
**How it works:** Provides a complete presentation structure for showcasing the pipeline toolkit to different audiences.

## 🔄 How Everything Works Together

### Pipeline Execution Flow

1. **Trigger:** A developer pushes code or creates a pull request
2. **Workflow Call:** The project's GitHub Actions workflow calls the reusable pipeline toolkit
3. **Stack Detection:** The pipeline identifies the application type (Node.js, Python, etc.)
4. **Parallel Execution:** Tests, dependency scans, and secret scans run simultaneously
5. **Docker Build:** The application is built into a Docker image and pushed to GHCR
6. **Image Scan:** The Docker image is scanned for vulnerabilities
7. **Branch Evaluation:** The pipeline checks which branch triggered the workflow
8. **Deployment:** Based on the branch, it deploys to staging (automatic) or production (manual approval)
9. **Health Check:** The deployed application is checked for health
10. **Rollback (if needed):** If health checks fail, automatic rollback is triggered

### Component Interactions

**GitHub Actions ↔ Composite Actions:**
- The main workflow delegates deployment to specialized actions
- Docker action handles VPS deployments
- K8s action handles Kubernetes deployments
- Both return deployment URLs for health checks

**Helm Chart ↔ Kubernetes:**
- The Helm chart defines the desired state
- Kubernetes applies the defined resources
- Helm manages releases and rollback history
- Values files provide environment-specific customization

**Scripts ↔ Pipeline:**
- Health check script validates deployments
- Rollback scripts handle failure recovery
- Canary scripts manage gradual rollouts
- Setup scripts prepare development environments

**Monitoring ↔ Infrastructure:**
- Prometheus collects metrics from all components
- Grafana visualizes the metrics
- Loki aggregates logs from applications
- Alerting rules trigger notifications

**Terraform ↔ Infrastructure:**
- Terraform provisions servers and clusters
- Terraform configures GitHub repositories
- Terraform deploys monitoring stack
- Outputs provide connection information

### Data Flow

**Configuration Flow:**
```
Project Config → Workflow Inputs → Action Parameters → Deployment Config → Infrastructure Changes
```

**Security Flow:**
```
Code → Trivy Scan → SARIF Report → GitHub Security Tab → Vulnerability Tracking
Code → Gitleaks Scan → SARIF Report → GitHub Security Tab → Secret Tracking
```

**Deployment Flow:**
```
Git Push → Workflow Trigger → Security Scans → Docker Build → Image Push → Deployment → Health Check → Success/Rollback
```

**Monitoring Flow:**
```
Application → Metrics → Prometheus → Grafana Dashboard → Visualization
Application → Logs → Promtail → Loki → Grafana Log Query → Log Analysis
```

### Integration Points

**GitHub Integration:**
- Workflow triggers (push, pull_request)
- Environment protection (manual approval)
- Security tab (SARIF reports)
- Secrets management (credentials)
- Status checks (pipeline results)

**Docker Integration:**
- GitHub Container Registry (image storage)
- Docker Compose (container orchestration)
- Multi-stage builds (optimized images)
- Health checks (container validation)

**Kubernetes Integration:**
- Helm (package management)
- Ingress (external access)
- ConfigMaps/Secrets (configuration)
- HPA/PDB (high availability)

**Security Integration:**
- Trivy (vulnerability scanning)
- Gitleaks (secret scanning)
- SARIF (standardized reporting)
- Severity gating (risk management)

## 🎯 Key Design Principles

### Reusability
- Single workflow for multiple projects
- Generic Helm chart for any application
- Composite actions for common operations
- Template-based configurations

### Security-First
- Built-in security scanning
- Secret management
- Vulnerability gating
- SARIF integration

### Flexibility
- Multiple deployment targets
- Environment-specific configurations
- Extensible scanning framework
- Custom hooks and scripts

### Reliability
- Automatic rollback on failure
- Health check validation
- Gradual canary deployments
- Comprehensive monitoring

### Observability
- Metrics collection (Prometheus)
- Log aggregation (Loki)
- Visualization (Grafana)
- Status dashboard

## 🚀 Extension Points

### Adding New Stacks
1. Add detection logic in `detect` job
2. Add setup steps for the stack
3. Create example configurations
4. Update documentation

### Adding New Security Scanners
1. Create parallel job in workflow
2. Configure SARIF output
3. Add to workflow execution
4. Update security documentation

### Adding New Deployment Targets
1. Create composite action
2. Add deployment logic
3. Integrate with workflow
4. Add rollback support
5. Update documentation

### Customizing Monitoring
1. Add custom Prometheus rules
2. Create Grafana dashboards
3. Configure additional data sources
4. Set up alerting channels

This comprehensive file explanation provides a complete understanding of every component in the Universal DevSecOps Pipeline Toolkit and how they work together to provide enterprise-grade DevSecOps capabilities.
