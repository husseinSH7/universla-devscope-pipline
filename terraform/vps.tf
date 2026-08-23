# Docker VPS configuration

resource "digitalocean_droplet" "docker_vps" {
  name   = "${var.project_name}-docker-vps"
  region = var.region
  size   = var.droplet_size
  image  = "ubuntu-22-04-x64"
  
  ssh_keys = [data.digitalocean_ssh_key.default_ssh_key.fingerprint]
  
  tags = ["devsecops", "docker", "pipeline-toolkit"]
  
  monitoring  = true
  backups     = true
  ipv6        = true
  
  user_data = <<-EOF
              #!/bin/bash
              # Update system
              apt-get update && apt-get upgrade -y
              
              # Install Docker
              curl -fsSL https://get.docker.com -o get-docker.sh
              sh get-docker.sh
              usermod -aG docker $USER
              
              # Install Docker Compose
              curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              
              # Configure firewall
              ufw allow 22/tcp
              ufw allow 80/tcp
              ufw allow 443/tcp
              ufw --force enable
              
              # Create app directory
              mkdir -p /opt/app
              chown -R $USER:$USER /opt/app
              
              echo "Docker VPS setup complete"
              EOF
}

data "digitalocean_ssh_key" "default_ssh_key" {
  name = "default"
}

resource "digitalocean_record" "docker_vps_a" {
  domain = data.digitalocean_domain.default.name
  name   = "docker"
  type   = "A"
  value  = digitalocean_droplet.docker_vps.ipv4_address
}

data "digitalocean_domain" "default" {
  name = var.domain_name
}
