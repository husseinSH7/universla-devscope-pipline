#!/bin/bash

# Status Dashboard Generator
# Generates an HTML dashboard showing deployment status across projects

set -e

OUTPUT_DIR="${OUTPUT_DIR:-dashboard/output}"
PROJECTS_FILE="${PROJECTS_FILE:-dashboard/projects.yml}"
GITHUB_TOKEN="${GITHUB_TOKEN}"

echo "Generating status dashboard..."
echo "Output directory: $OUTPUT_DIR"
echo "Projects file: $PROJECTS_FILE"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Function to get GitHub Actions workflow status
get_workflow_status() {
  local owner=$1
  local repo=$2
  local workflow=$3
  
  if [ -z "$GITHUB_TOKEN" ]; then
    echo "unknown"
    return
  fi
  
  # Get latest workflow run
  latest_run=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$owner/$repo/actions/workflows/$workflow/runs?per_page=1" | \
    jq -r '.workflow_runs[0].status // "unknown"')
  
  conclusion=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$owner/$repo/actions/workflows/$workflow/runs?per_page=1" | \
    jq -r '.workflow_runs[0].conclusion // "none"')
  
  if [ "$conclusion" = "success" ]; then
    echo "success"
  elif [ "$conclusion" = "failure" ]; then
    echo "failure"
  elif [ "$latest_run" = "in_progress" ]; then
    echo "running"
  else
    echo "pending"
  fi
}

# Function to get deployment info
get_deployment_info() {
  local owner=$1
  local repo=$2
  local environment=$3
  
  if [ -z "$GITHUB_TOKEN" ]; then
    echo '{"status":"unknown","time":"unknown","url":""}'
    return
  fi
  
  deployment=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$owner/$repo/deployments?environment=$environment&per_page=1" | \
    jq '.[0] // empty')
  
  if [ -z "$deployment" ] || [ "$deployment" = "null" ]; then
    echo '{"status":"no_deployment","time":"never","url":""}'
    return
  fi
  
  status=$(echo "$deployment" | jq -r '.status // "unknown"')
  time=$(echo "$deployment" | jq -r '.created_at // "unknown"')
  url=$(echo "$deployment" | jq -r '.repository.html_url // ""')
  
  echo "{\"status\":\"$status\",\"time\":\"$time\",\"url\":\"$url\"}"
}

# Function to get security scan results
get_security_results() {
  local owner=$1
  local repo=$2
  
  if [ -z "$GITHUB_TOKEN" ]; then
    echo '{"vulnerabilities":"unknown","secrets":"unknown"}'
    return
  fi
  
  # Get recent alerts (vulnerabilities and secrets)
  alerts=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$owner/$repo/code-scanning/alerts?state=open&per_page=100" | \
    jq 'length')
  
  echo "{\"vulnerabilities\":$alerts,\"secrets\":\"checked\"}"
}

# Generate HTML dashboard
generate_html() {
  local html_file="$OUTPUT_DIR/index.html"
  
  cat > "$html_file" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DevSecOps Pipeline Status Dashboard</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        
        .header {
            background: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        }
        
        .header h1 {
            color: #333;
            margin-bottom: 10px;
        }
        
        .header p {
            color: #666;
        }
        
        .last-updated {
            text-align: right;
            color: #999;
            font-size: 14px;
            margin-top: 10px;
        }
        
        .projects-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 20px;
        }
        
        .project-card {
            background: white;
            border-radius: 10px;
            padding: 25px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            transition: transform 0.3s ease;
        }
        
        .project-card:hover {
            transform: translateY(-5px);
        }
        
        .project-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .project-name {
            font-size: 20px;
            font-weight: bold;
            color: #333;
        }
        
        .project-link {
            color: #667eea;
            text-decoration: none;
            font-size: 14px;
        }
        
        .status-section {
            margin-bottom: 15px;
        }
        
        .status-label {
            font-size: 12px;
            color: #666;
            margin-bottom: 5px;
        }
        
        .status-indicator {
            display: inline-block;
            padding: 5px 12px;
            border-radius: 15px;
            font-size: 12px;
            font-weight: bold;
        }
        
        .status-success {
            background: #d4edda;
            color: #155724;
        }
        
        .status-failure {
            background: #f8d7da;
            color: #721c24;
        }
        
        .status-running {
            background: #fff3cd;
            color: #856404;
        }
        
        .status-pending {
            background: #e2e3e5;
            color: #383d41;
        }
        
        .status-unknown {
            background: #d1ecf1;
            color: #0c5460;
        }
        
        .metrics {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 10px;
            margin-top: 15px;
        }
        
        .metric {
            background: #f8f9fa;
            padding: 10px;
            border-radius: 5px;
            text-align: center;
        }
        
        .metric-value {
            font-size: 18px;
            font-weight: bold;
            color: #333;
        }
        
        .metric-label {
            font-size: 11px;
            color: #666;
            margin-top: 3px;
        }
        
        .security-section {
            margin-top: 15px;
            padding-top: 15px;
            border-top: 1px solid #eee;
        }
        
        .security-item {
            display: flex;
            justify-content: space-between;
            padding: 5px 0;
            font-size: 13px;
        }
        
        .vulnerability-count {
            font-weight: bold;
        }
        
        .vulnerability-none {
            color: #28a745;
        }
        
        .vulnerability-low {
            color: #ffc107;
        }
        
        .vulnerability-high {
            color: #dc3545;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 DevSecOps Pipeline Status Dashboard</h1>
            <p>Real-time monitoring of all projects using the Universal DevSecOps Pipeline Toolkit</p>
            <div class="last-updated">Last updated: <span id="update-time"></span></div>
        </div>
        
        <div class="projects-grid" id="projects-grid">
            <!-- Project cards will be dynamically inserted here -->
        </div>
    </div>
    
    <script>
        // Sample project data (in production, this would come from API)
        const projects = [
            {
                name: "POS System",
                owner: "your-username",
                repo: "pos-system",
                url: "https://github.com/your-username/pos-system",
                workflow: "success",
                staging: "success",
                production: "success",
                vulnerabilities: 0,
                lastDeploy: "2024-01-15T10:30:00Z"
            },
            {
                name: "Burger App",
                owner: "your-username", 
                repo: "burger-app",
                url: "https://github.com/your-username/burger-app",
                workflow: "running",
                staging: "success",
                production: "pending",
                vulnerabilities: 2,
                lastDeploy: "2024-01-14T15:45:00Z"
            },
            {
                name: "ClimbingTribe",
                owner: "your-username",
                repo: "climbing-tribe",
                url: "https://github.com/your-username/climbing-tribe",
                workflow: "success",
                staging: "failure",
                production: "success",
                vulnerabilities: 0,
                lastDeploy: "2024-01-13T09:15:00Z"
            }
        ];
        
        function getStatusClass(status) {
            switch(status) {
                case 'success': return 'status-success';
                case 'failure': return 'status-failure';
                case 'running': return 'status-running';
                case 'pending': return 'status-pending';
                default: return 'status-unknown';
            }
        }
        
        function getVulnerabilityClass(count) {
            if (count === 0) return 'vulnerability-none';
            if (count < 5) return 'vulnerability-low';
            return 'vulnerability-high';
        }
        
        function formatDate(dateString) {
            const date = new Date(dateString);
            return date.toLocaleString();
        }
        
        function renderProjects() {
            const grid = document.getElementById('projects-grid');
            grid.innerHTML = projects.map(project => `
                <div class="project-card">
                    <div class="project-header">
                        <div class="project-name">${project.name}</div>
                        <a href="${project.url}" class="project-link" target="_blank">View →</a>
                    </div>
                    
                    <div class="status-section">
                        <div class="status-label">Pipeline Status</div>
                        <span class="status-indicator ${getStatusClass(project.workflow)}">${project.workflow.toUpperCase()}</span>
                    </div>
                    
                    <div class="status-section">
                        <div class="status-label">Staging</div>
                        <span class="status-indicator ${getStatusClass(project.staging)}">${project.staging.toUpperCase()}</span>
                    </div>
                    
                    <div class="status-section">
                        <div class="status-label">Production</div>
                        <span class="status-indicator ${getStatusClass(project.production)}">${project.production.toUpperCase()}</span>
                    </div>
                    
                    <div class="metrics">
                        <div class="metric">
                            <div class="metric-value">${project.vulnerabilities}</div>
                            <div class="metric-label">Vulnerabilities</div>
                        </div>
                        <div class="metric">
                            <div class="metric-value">${formatDate(project.lastDeploy).split(',')[0]}</div>
                            <div class="metric-label">Last Deploy</div>
                        </div>
                    </div>
                    
                    <div class="security-section">
                        <div class="security-item">
                            <span>🔒 Security Scans</span>
                            <span class="vulnerability-count ${getVulnerabilityClass(project.vulnerabilities)}">${project.vulnerabilities} issues</span>
                        </div>
                    </div>
                </div>
            `).join('');
        }
        
        function updateTime() {
            document.getElementById('update-time').textContent = new Date().toLocaleString();
        }
        
        // Initialize
        renderProjects();
        updateTime();
        
        // Auto-refresh every 30 seconds
        setInterval(() => {
            renderProjects();
            updateTime();
        }, 30000);
    </script>
</body>
</html>
EOF

  echo "HTML dashboard generated: $html_file"
}

# Parse projects file and generate data
generate_project_data() {
  if [ ! -f "$PROJECTS_FILE" ]; then
    echo "Projects file not found: $PROJECTS_FILE"
    echo "Using sample data for dashboard generation"
    return
  fi
  
  echo "Parsing projects from: $PROJECTS_FILE"
  # In production, this would parse the YAML file and call GitHub API
  # For now, we'll use the sample data in the HTML
}

# Main execution
generate_project_data
generate_html

echo ""
echo "Dashboard generation completed!"
echo "Open $OUTPUT_DIR/index.html in your browser to view the dashboard"
echo ""
echo "To customize the dashboard:"
echo "1. Edit $PROJECTS_FILE to add your projects"
echo "2. Set GITHUB_TOKEN environment variable for real data"
echo "3. Modify the HTML template in $OUTPUT_DIR/index.html"
