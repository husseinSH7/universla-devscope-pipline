# Demo Script for Universal DevSecOps Pipeline Toolkit

This script provides a structured demonstration of the Universal DevSecOps Pipeline Toolkit.

## Demo Setup

### Pre-Demo Checklist
- [ ] Have a sample project ready
- [ ] Ensure GitHub repository is accessible
- [ ] Have Docker/Kubernetes environment available
- [ ] Prepare test credentials
- [ ] Set up monitoring dashboard
- [ ] Have status dashboard ready

### Environment Setup
```bash
# Clone the toolkit
git clone https://github.com/your-username/pipeline-toolkit.git
cd pipeline-toolkit

# Make scripts executable
chmod +x scripts/*.sh

# Setup local Kubernetes cluster (optional)
./scripts/k8s-setup.sh kind
```

## Demo Script

### Introduction (2 minutes)

**Speaker Notes:**
"Today I'm going to demonstrate the Universal DevSecOps Pipeline Toolkit - a reusable, stack-agnostic CI/CD pipeline that provides enterprise-grade DevSecOps capabilities for personal projects."

**Key Points to Cover:**
- Problem: Maintaining separate CI/CD pipelines for each project
- Solution: Single reusable pipeline toolkit
- Benefits: Security-first, dual deployment targets, environment promotion
- Stack-agnostic: Works with Node.js, Python, Go, Rust

### Architecture Overview (3 minutes)

**Demo Actions:**
```bash
# Show project structure
ls -la
tree -L 2

# Display architecture diagram
cat README.md | head -30
```

**Speaker Notes:**
"The toolkit uses a modular architecture where each project calls a central reusable workflow. This means you maintain the pipeline logic once, and all your projects benefit automatically."

### Project Integration (5 minutes)

**Demo Actions:**
```bash
# Show example workflow
cat examples/workflow-nodejs.yml

# Show example Dockerfile
cat Dockerfile.example

# Show pipeline configuration
cat examples/pipeline-config.yml
```

**Speaker Notes:**
"Integration is incredibly simple. Each project only needs:
1. A 10-line GitHub Actions workflow
2. A Dockerfile (we provide templates)
3. Optional pipeline configuration
That's it - no complex pipeline maintenance per project."

### Security Scanning (4 minutes)

**Demo Actions:**
```bash
# Show security scanning configuration
grep -A 10 "dependency-scan\|secret-scan" .github/workflows/pipeline.yml

# Explain SARIF integration
grep -A 5 "upload-sarif" .github/workflows/pipeline.yml
```

**Speaker Notes:**
"Security is built-in from the start. We run Trivy for dependency scanning and Gitleaks for secret detection in parallel. Results automatically appear in GitHub's Security tab for tracking and trending."

### Docker Deployment (4 minutes)

**Demo Actions:**
```bash
# Show Docker deployment action
cat .github/actions/docker-deploy/action.yml

# Show Docker Compose configurations
cat docker-compose.staging.yml
cat docker-compose.production.yml
```

**Speaker Notes:**
"For Docker deployments, we provide SSH-based deployment to VPS, with automatic health checks and rollback capabilities. The same pipeline can deploy to different environments with simple configuration changes."

### Kubernetes Deployment (4 minutes)

**Demo Actions:**
```bash
# Show Helm chart structure
ls -la chart/templates/

# Show Helm values
cat chart/values.yaml
cat chart/values-staging.yaml
cat chart/values-production.yaml

# Explain canary deployment
cat chart/values-canary.yaml
```

**Speaker Notes:**
"For Kubernetes, we provide a complete Helm chart with environment-specific configurations. The chart supports advanced features like horizontal pod autoscaling, pod disruption budgets, and canary deployments."

### Environment Promotion (3 minutes)

**Demo Actions:**
```bash
# Show environment configuration in workflow
grep -A 15 "deploy-staging\|deploy-production" .github/workflows/pipeline.yml

# Explain branch-based deployment
echo "develop branch → automatic staging deployment"
echo "main branch → manual approval → production deployment"
```

**Speaker Notes:**
"Environment promotion is automated based on Git branches. Push to develop automatically deploys to staging, while production requires manual approval through GitHub's environment protection."

### Health Checks & Rollback (3 minutes)

**Demo Actions:**
```bash
# Show health check script
cat scripts/health-check.sh

# Show rollback scripts
cat scripts/docker-rollback.sh
cat scripts/k8s-rollback.sh
```

**Speaker Notes:**
"Every deployment includes automatic health checks. If the health check fails, the pipeline automatically rolls back to the previous version - no manual intervention required for most failures."

### Monitoring & Observability (3 minutes)

**Demo Actions:**
```bash
# Show monitoring setup
ls -la monitoring/

# Show Prometheus configuration
cat monitoring/prometheus-values.yaml

# Show Grafana dashboard
cat monitoring/grafana-dashboards/deployment-dashboard.json
```

**Speaker Notes:**
"Complete observability is included with Prometheus, Grafana, and Loki for log aggregation. Pre-configured dashboards show deployment status, resource usage, and application metrics."

### Status Dashboard (2 minutes)

**Demo Actions:**
```bash
# Generate status dashboard
./dashboard/generate-dashboard.sh

# Show dashboard HTML
cat dashboard/output/index.html
```

**Speaker Notes:**
"The status dashboard provides a real-time view of all projects using the pipeline, showing deployment status, security scan results, and last deployment times across all your projects."

### Infrastructure as Code (2 minutes)

**Demo Actions:**
```bash
# Show Terraform configuration
ls -la terraform/
cat terraform/main.tf
cat terraform/vps.tf
cat terraform/k8s.tf
```

**Speaker Notes:**
"Infrastructure can be provisioned using Terraform, supporting both Docker VPS and Kubernetes clusters. This ensures consistent, repeatable infrastructure setup."

### Live Demo (5 minutes)

**Demo Actions:**
```bash
# Trigger a pipeline run
git checkout -b demo-branch
echo "test change" >> test.txt
git add test.txt
git commit -m "Demo: Test pipeline trigger"
git push origin demo-branch

# Monitor the pipeline
echo "Navigate to GitHub Actions to see the pipeline running"
```

**Speaker Notes:**
"Now let's see the pipeline in action. I'll push a change and watch it go through the complete process: stack detection, security scanning, Docker build, and deployment."

### Q&A (5 minutes)

**Common Questions to Anticipate:**

**Q: How much does this cost to run?**
A: GitHub Actions is free for public repositories and generous for private ones. Infrastructure costs depend on your chosen cloud provider.

**Q: Can I customize the pipeline for my specific needs?**
A: Absolutely. The pipeline is designed to be extensible - you can add custom security scanners, modify deployment logic, or add additional stages.

**Q: What if I don't have Kubernetes experience?**
A: Start with Docker deployment. The Kubernetes support is there when you're ready, but you don't need it to benefit from the pipeline.

**Q: How does this compare to enterprise solutions like GitLab CI or Jenkins?**
A: This provides similar capabilities but with a simpler, more focused approach. It's designed specifically for the needs of personal projects and small teams.

### Conclusion (2 minutes)

**Speaker Notes:**
"The Universal DevSecOps Pipeline Toolkit provides enterprise-grade DevSecOps capabilities without the enterprise complexity. It's:

- **Reusable**: One pipeline, many projects
- **Secure**: Built-in scanning and gating
- **Flexible**: Docker and Kubernetes support
- **Production-ready**: Environments, rollback, monitoring
- **Well-documented**: Complete guides and examples

Start by adding it to one of your projects, and gradually adopt it across your portfolio. The modular design lets you use what you need and extend what you don't."

## Demo Variations

### Quick Demo (10 minutes)
- Skip Terraform and monitoring sections
- Focus on core pipeline functionality
- Show one deployment target only
- Use pre-generated dashboard

### Technical Deep Dive (30 minutes)
- Include Terraform infrastructure setup
- Show advanced Kubernetes features
- Demonstrate canary deployment
- Detailed monitoring walkthrough
- Advanced configuration options

### Executive Overview (5 minutes)
- Focus on business benefits
- Show high-level architecture
- Demonstrate ease of use
- Show end result (status dashboard)
- Skip technical details

## Demo Tips

### Before the Demo
- Test everything in the demo environment
- Have backup plans for failing demos
- Prepare answers to common questions
- Set up monitoring to show real-time data
- Have a working example project ready

### During the Demo
- Speak clearly and at a measured pace
- Use visual aids (diagrams, screenshots)
- Explain the "why" not just the "how"
- Be prepared to adapt to audience questions
- Keep technical jargon to a minimum

### After the Demo
- Provide resources for further learning
- Offer to help with implementation
- Collect feedback for improvement
- Share demo materials with attendees
- Follow up on promised actions

## Common Demo Issues & Solutions

### Issue: Pipeline fails during demo
**Solution**: Have a pre-recorded video backup, explain how failures are handled with rollback

### Issue: External services unavailable
**Solution**: Use mock services, explain how this would work in production

### Issue: Network connectivity problems
**Solution**: Have local alternatives ready, focus on architecture rather than live execution

### Issue: Time running short
**Solution**: Have abbreviated version ready, skip to most important sections

## Follow-up Materials

Provide attendees with:
- Link to GitHub repository
- Quick start guide
- Architecture documentation
- Contact information for support
- Schedule for follow-up sessions
