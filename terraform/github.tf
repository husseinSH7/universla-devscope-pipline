# GitHub repository configuration

resource "github_repository" "pipeline_toolkit" {
  name        = "pipeline-toolkit"
  description = "Universal DevSecOps Pipeline Toolkit - A reusable, stack-agnostic CI/CD pipeline"
  visibility  = "public"
  
  has_issues        = true
  has_wiki          = true
  has_projects      = true
  has_downloads     = true
  
  auto_init = true
  
  # Branch protection
  branch_protection {
    pattern        = "main"
    enforce_admins = true
    
    required_pull_request_reviews {
      required_approving_review_count = 1
    }
    
    required_status_checks {
      strict = true
    }
    
    require_branch_up_to_date = true
  }
  
  # Environments
  environment {
    name = "staging"
    deployment_branch_policy {
      custom_branches {
        name = "develop"
      }
    }
  }
  
  environment {
    name = "production"
    deployment_branch_policy {
      custom_branches {
        name = "main"
      }
    }
  }
  
  topics = ["devsecops", "ci-cd", "docker", "kubernetes", "github-actions", "security"]
}

# GitHub Actions secrets for the repository
resource "github_actions_secret" "ssh_host" {
  repository       = github_repository.pipeline_toolkit.name
  secret_name      = "SSH_HOST"
  plaintext_value  = digitalocean_droplet.docker_vps.ipv4_address
}

resource "github_actions_secret" "kube_config" {
  repository       = github_repository.pipeline_toolkit.name
  secret_name      = "KUBE_CONFIG"
  plaintext_value  = base64encode(digitalocean_kubernetes_cluster.k8s_cluster.kube_config[0].raw_config)
}
