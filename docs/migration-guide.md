# Migration Guide

This guide helps you migrate existing projects to use the Universal DevSecOps Pipeline Toolkit.

## Assessment Phase

### Current State Analysis

Before migrating, analyze your current CI/CD setup:

1. **Current Pipeline Type**
   - GitHub Actions
   - GitLab CI
   - Jenkins
   - CircleCI
   - Other

2. **Deployment Method**
   - Manual deployment
   - Docker Compose
   - Kubernetes
   - Other container orchestration
   - Traditional deployment

3. **Security Scanning**
   - No security scanning
   - Basic dependency scanning
   - Comprehensive security pipeline
   - Manual security reviews

4. **Environments**
   - Single environment
   - Development/Production
   - Development/Staging/Production
   - Multiple custom environments

## Pre-Migration Checklist

- [ ] Backup current CI/CD configuration
- [ ] Document current deployment process
- [ ] Identify environment-specific configurations
- [ ] List all current security scans
- [ ] Document rollback procedures
- [ ] Identify required secrets and credentials
- [ ] Document current monitoring and logging
- [ ] Notify team of upcoming migration

## Migration Strategies

### Strategy 1: Gradual Migration (Recommended)

适合复杂的现有项目，风险较低。

#### Phase 1: Add Security Scanning
1. Keep existing pipeline
2. Add Trivy and Gitleaks scanning as parallel jobs
3. Integrate SARIF reports
4. Test and validate

#### Phase 2: Add Build and Push
1. Add Docker build stage
2. Configure GitHub Container Registry
3. Test image builds locally
4. Implement in pipeline

#### Phase 3: Add Deployment
1. Choose deployment target (Docker/K8s)
2. Set up deployment infrastructure
3. Configure deployment stage
4. Test with staging environment

#### Phase 4: Replace Existing Pipeline
1. Migrate environment configurations
2. Replace old pipeline with new
3. Monitor for issues
4. Remove old pipeline after validation

### Strategy 2: Parallel Migration

运行新旧并行一段时间，适合关键系统。

1. Create new pipeline alongside existing
2. Configure different branch triggers
3. Compare results between pipelines
4. Gradually shift traffic to new pipeline
5. Decommission old pipeline

### Strategy 3: Big Bang Migration

一次性替换，适合简单项目。

1. Complete preparation
2. Schedule maintenance window
3. Deploy new pipeline
4. Validate thoroughly
5. Handle rollback if needed

## Step-by-Step Migration

### Step 1: Repository Preparation

```bash
# Clone the pipeline toolkit
git clone https://github.com/your-username/pipeline-toolkit.git
cd pipeline-toolkit

# Review the structure
ls -la
```

### Step 2: Add GitHub Actions Workflow

```bash
# In your project repository
mkdir -p .github/workflows

# Copy example workflow
cp pipeline-toolkit/examples/workflow-nodejs.yml .github/workflows/ci.yml
```

### Step 3: Create Dockerfile

```bash
# Copy example Dockerfile
cp pipeline-toolkit/Dockerfile.example Dockerfile

# Customize for your application
# - Update base image
# - Adjust build steps
# - Set correct entrypoint
# - Add health checks
```

### Step 4: Configure Pipeline

```bash
# Create pipeline configuration
cat > pipeline.yml << EOF
scanners: [trivy, gitleaks]
severity_gate: HIGH
deploy_target: docker
canary: false
EOF
```

### Step 5: Add Required Secrets

In your GitHub repository settings, add:

**For Docker deployment:**
- `SSH_HOST`: Your VPS hostname/IP
- `SSH_USERNAME`: SSH username
- `SSH_KEY`: Private SSH key

**For Kubernetes deployment:**
- `KUBE_CONFIG`: Base64-encoded kubeconfig

### Step 6: Test Locally

```bash
# Test Docker build
docker build -t test-app .

# Test Docker Compose (if using)
docker-compose -f docker-compose.yml config

# Test Helm chart (if using K8s)
helm lint ./chart
```

### Step 7: Create Pull Request

```bash
# Create feature branch
git checkout -b feature/migrate-to-pipeline-toolkit

# Commit changes
git add .github/workflows/ci.yml Dockerfile pipeline.yml
git commit -m "Migrate to Universal DevSecOps Pipeline Toolkit"

# Push and create PR
git push origin feature/migrate-to-pipeline-toolkit
```

### Step 8: Validate Pipeline

1. Review PR workflow run
2. Check security scan results
3. Verify Docker build succeeds
4. Test deployment (if configured)
5. Review SARIF reports in Security tab

### Step 9: Deploy to Staging

```bash
# Merge to develop branch
git checkout develop
git merge feature/migrate-to-pipeline-toolkit
git push origin develop

# Monitor staging deployment
```

### Step 10: Production Deployment

```bash
# Create PR to main
git checkout main
git merge develop
git push origin main

# Request approval for production deployment
# Monitor production deployment
# Perform smoke tests
```

## Common Migration Challenges

### Challenge 1: Complex Build Process

**Problem:** Your current build process is complex and doesn't fit the standard Docker build.

**Solution:**
- Create a custom build script
- Use multi-stage Dockerfile
- Implement build caching
- Consider build tools like Make

### Challenge 2: Legacy Dependencies

**Problem:** Application has dependencies that are hard to containerize.

**Solution:**
- Update dependencies where possible
- Use compatibility layers
- Create custom base images
- Implement workarounds in Dockerfile

### Challenge 3: Environment Variables

**Problem:** Complex environment variable configuration across environments.

**Solution:**
- Use environment-specific value files
- Implement Kubernetes ConfigMaps/Secrets
- Use Docker Compose environment files
- Consider secret management tools

### Challenge 4: Database Migrations

**Problem:** Database migrations need to run during deployment.

**Solution:**
- Add migration step to Dockerfile
- Implement migration hooks in Helm chart
- Use init containers in Kubernetes
- Add migration stage to pipeline

### Challenge 5: Static Assets

**Problem:** Large static assets that need special handling.

**Solution:**
- Use multi-stage builds
- Implement CDN integration
- Optimize asset delivery
- Consider separate asset deployment

## Post-Migration Validation

### Functional Testing

- [ ] Application starts successfully
- [ ] All endpoints respond correctly
- [ ] Database connections work
- [ ] External integrations function
- [ ] Authentication/authorization works

### Performance Testing

- [ ] Response times are acceptable
- [ ] Resource usage is normal
- [ ] Error rates are low
- [ ] Throughput meets requirements

### Security Testing

- [ ] No new vulnerabilities introduced
- [ ] Security scans pass
- [ ] Secrets are properly protected
- [ ] Access controls are maintained

### Monitoring Validation

- [ ] Logs are being collected
- [ ] Metrics are being recorded
- [ ] Alerts are configured
- [ ] Dashboards are working

## Rollback Plan

### Immediate Rollback

If critical issues are detected:

1. **Docker Rollback:**
   ```bash
   ./scripts/docker-rollback.sh production
   ```

2. **Kubernetes Rollback:**
   ```bash
   ./scripts/k8s-rollback.sh production
   ```

3. **Code Rollback:**
   ```bash
   git revert <commit-hash>
   git push origin main
   ```

### Partial Rollback

If only specific components fail:

1. Rollback specific services
2. Disable problematic features
3. Revert specific configuration changes
4. Implement temporary workarounds

## Migration Timeline

### Small Project (1-2 days)
- Day 1: Preparation and testing
- Day 2: Migration and validation

### Medium Project (1 week)
- Day 1-2: Assessment and planning
- Day 3-4: Implementation and testing
- Day 5: Deployment and validation

### Large Project (2-4 weeks)
- Week 1: Assessment and detailed planning
- Week 2: Implementation and testing
- Week 3: Staging deployment and validation
- Week 4: Production deployment and monitoring

## Best Practices

### During Migration
- Maintain detailed documentation
- Communicate regularly with team
- Test thoroughly at each stage
- Have rollback plans ready
- Monitor system closely

### After Migration
- Update documentation
- Train team on new processes
- Optimize pipeline performance
- Implement additional monitoring
- Plan for continuous improvement

## Support and Resources

- **Documentation:** See [docs/](./) folder
- **Examples:** See [examples/](../examples/) folder
- **Troubleshooting:** See [troubleshooting.md](./troubleshooting.md)
- **GitHub Issues:** Report problems in the repository
- **Community:** Join discussions for community support

## Success Criteria

Migration is considered successful when:

- ✅ New pipeline runs without errors
- ✅ Security scans pass consistently
- ✅ Deployments complete successfully
- ✅ Application functions correctly
- ✅ Team is comfortable with new process
- ✅ Monitoring and alerting work properly
- ✅ Rollback procedures are tested
- ✅ Documentation is updated

## Next Steps

After successful migration:

1. **Optimize Pipeline**
   - Reduce build times
   - Improve caching strategies
   - Optimize resource usage

2. **Enhance Security**
   - Add additional security scanners
   - Implement policy checks
   - Strengthen access controls

3. **Improve Monitoring**
   - Add custom metrics
   - Create additional dashboards
   - Implement advanced alerting

4. **Team Training**
   - Conduct training sessions
   - Create runbooks
   - Document best practices

Congratulations on migrating to the Universal DevSecOps Pipeline Toolkit!
