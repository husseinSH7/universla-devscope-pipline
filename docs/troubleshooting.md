# Troubleshooting Guide

This guide helps you diagnose and fix common issues with the Universal DevSecOps Pipeline Toolkit.

## GitHub Actions Issues

### Workflow Fails to Start

**Symptoms:** Workflow doesn't appear in Actions tab or fails immediately

**Solutions:**
- Verify workflow file is in `.github/workflows/` directory
- Check YAML syntax (use a YAML validator)
- Ensure the workflow file has the correct extension `.yml` or `.yaml`
- Verify GitHub Actions is enabled in repository settings

### Authentication Failures

**Symptoms:** Permission denied or authentication errors in workflow logs

**Solutions:**
- Check that `github_token` is being passed correctly
- Verify GitHub Actions has permission to access the repository
- For external repositories, ensure proper PAT token usage
- Check repository visibility and collaboration settings

### Reusable Workflow Not Found

**Symptoms:** Error "Reusable workflow not found" when calling pipeline-toolkit

**Solutions:**
- Verify the workflow path is correct: `.github/workflows/pipeline.yml`
- Ensure the pipeline-toolkit repository is public or you have access
- Check the version reference (@main, @v1.0.0, etc.)
- Verify the repository name and owner are correct

## Docker Issues

### Build Failures

**Symptoms:** Docker build fails during pipeline execution

**Solutions:**
- Test Docker build locally: `docker build -t test .`
- Check Dockerfile syntax and base image availability
- Verify build context path is correct
- Ensure all required files are present in the repository
- Check for large file sizes or missing dependencies

### Push Failures

**Symptoms:** Docker push to GHCR fails

**Solutions:**
- Verify GitHub Container Registry is enabled for your account
- Check that the image name format is correct: `ghcr.io/owner/repo`
- Ensure you have write permissions to the repository
- Verify the authentication token has correct scopes
- Check for rate limiting on GHCR

### SSH Deployment Failures

**Symptoms:** SSH connection fails during deployment

**Solutions:**
- Test SSH connection manually: `ssh user@host`
- Verify SSH credentials in GitHub Secrets
- Check VPS firewall allows SSH connections
- Ensure the SSH key format is correct (no extra whitespace)
- Verify the user has sudo permissions for Docker operations

### Container Startup Failures

**Symptoms:** Containers fail to start after deployment

**Solutions:**
- Check container logs: `docker-compose logs`
- Verify environment variables are correctly set
- Ensure port mappings don't conflict
- Check for missing volumes or mount points
- Verify the application health check endpoints

## Kubernetes Issues

### Cluster Connection Failures

**Symptoms:** Unable to connect to Kubernetes cluster

**Solutions:**
- Verify kubeconfig file is valid: `kubectl cluster-info`
- Check kubeconfig is correctly base64 encoded in secrets
- Test cluster connectivity manually
- Verify the cluster is running and accessible
- Check for VPN or network requirements

### Helm Deployment Failures

**Symptoms:** Helm upgrade or install fails

**Solutions:**
- Test Helm chart locally: `helm lint ./chart`
- Verify chart dependencies are installed
- Check for syntax errors in values files
- Ensure namespace exists or can be created
- Verify Helm version compatibility

### Pod Startup Failures

**Symptoms:** Pods fail to start or are in CrashLoopBackOff

**Solutions:**
- Check pod logs: `kubectl logs pod-name`
- Describe pod for detailed error: `kubectl describe pod pod-name`
- Verify image pull secrets are configured
- Check resource limits and requests
- Ensure application configuration is correct

### Ingress Issues

**Symptoms:** Unable to access application via ingress

**Solutions:**
- Verify ingress controller is installed and running
- Check ingress controller logs for errors
- Ensure DNS records point to correct IP
- Verify ingress resource configuration
- Check for TLS certificate issues

## Security Scanning Issues

### Trivy Scan Failures

**Symptoms:** Trivy scans fail or timeout

**Solutions:**
- Check Trivy version compatibility
- Verify network connectivity for vulnerability database
- Adjust timeout settings if needed
- Check for large dependency trees
- Review Trivy configuration for custom rules

### Gitleaks Failures

**Symptoms:** Gitleaks detects false positives or fails

**Solutions:**
- Review and update Gitleaks configuration
- Add exceptions for allowed patterns
- Verify commit history doesn't contain actual secrets
- Check for custom rule syntax errors
- Update Gitleaks version if needed

### SARIF Upload Failures

**Symptoms:** SARIF reports fail to upload to GitHub Security

**Solutions:**
- Verify GitHub Actions token has security events permission
- Check SARIF file format is valid
- Ensure file path is correct in workflow
- Verify repository has Security tab enabled
- Check for file size limitations

## Environment Issues

### Staging Deployment Failures

**Symptoms:** Deployments to staging environment fail

**Solutions:**
- Verify `develop` branch exists and is configured
- Check staging environment configuration
- Ensure staging infrastructure is available
- Review staging-specific values and settings
- Check for resource constraints in staging

### Production Approval Failures

**Symptoms:** Production deployment requires approval but fails

**Solutions:**
- Verify GitHub Environment is configured
- Check required reviewers are set
- Ensure reviewers have repository access
- Verify approval timeout settings
- Check for branch protection rule conflicts

## Rollback Issues

### Docker Rollback Failures

**Symptoms:** Docker rollback fails or doesn't restore previous version

**Solutions:**
- Verify previous image tag is stored correctly
- Check Docker Compose file permissions
- Ensure SSH access is still working
- Verify image still exists in registry
- Test rollback manually first

### Kubernetes Rollback Failures

**Symptoms:** Helm rollback fails or doesn't restore previous version

**Solutions:**
- Check Helm release history: `helm history release-name`
- Verify previous revision exists
- Ensure Helm can connect to cluster
- Check for resource conflicts during rollback
- Verify rollback command syntax

## Performance Issues

### Slow Pipeline Execution

**Symptoms:** Pipeline takes longer than expected

**Solutions:**
- Check for unnecessary steps in workflow
- Optimize Docker build with caching
- Use matrix strategy for parallel jobs
- Reduce security scan scope if appropriate
- Consider using GitHub Actions cache

### High Resource Usage

**Symptoms:** Pipeline or deployment uses excessive resources

**Solutions:**
- Adjust resource limits in Kubernetes
- Optimize Docker image size
- Use multi-stage builds effectively
- Implement resource quotas in namespaces
- Monitor and tune container resource limits

## Getting Additional Help

If you're still experiencing issues:

1. **Check Logs:** Review all available logs (GitHub Actions, Docker, Kubernetes)
2. **Test Locally:** Reproduce the issue in your local environment
3. **Consult Documentation:** Review relevant documentation
4. **Community Support:** Check GitHub Issues or discussions
5. **Minimal Reproduction:** Create a minimal case that demonstrates the issue

## Prevention and Best Practices

To avoid common issues:

- Test changes locally before pushing
- Use feature branches and pull requests
- Monitor pipeline execution regularly
- Keep dependencies updated
- Review security scan results promptly
- Maintain proper documentation
- Use version tags for releases
- Implement proper monitoring and alerting
