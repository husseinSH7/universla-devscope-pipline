# Universal DevSecOps Pipeline — Full Design Documentation

**Project name suggestion:** `pipeline-toolkit` (or brand it under whatever studio name you're using for your portfolio)

**One-line pitch:** A reusable, stack-agnostic CI/CD pipeline that any of your projects can plug into, with built-in security scanning, staged environments, and safe rollout/rollback — supporting both Docker and Kubernetes deploy targets.

This doc combines everything discussed into one coherent architecture, split into a **core tier** (build this first, it's your MVP) and a **stretch tier** (add if time allows, ordered by impact-per-effort).

---

## 1. Architecture overview

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

Each project repo has a tiny `pipeline.yml` config and a one-line workflow that calls the shared toolkit. All the real logic lives in one place — you maintain it once, every project benefits.

---

## 2. Pipeline stages (execution order)

```
push/PR
   │
   ├──▶ detect-stack        (what language/framework is this?)
   │
   ├──▶ test        ┐
   ├──▶ dep-scan     ├─ run in parallel
   ├──▶ secret-scan  ┘
   │
   ├──▶ build-image        (Docker build, tag with commit SHA)
   ├──▶ image-scan         (Trivy on the built image)
   │
   ├──▶ [branch = develop] ──▶ deploy-staging ──▶ smoke-test
   │
   └──▶ [branch = main] ──▶ manual approval gate ──▶ deploy-prod
                                                          │
                                                          ├─ canary (10%) ──▶ health check
                                                          │        │
                                                          │      pass → full rollout
                                                          │      fail → auto-rollback
```

---

## 3. Core tier (build this — it's your MVP and resume line on its own)

### 3.1 Stack auto-detection
A `detect` job that inspects the calling repo and sets outputs used by later jobs:

```yaml
jobs:
  detect:
    runs-on: ubuntu-latest
    outputs:
      stack: ${{ steps.detect.outputs.stack }}
    steps:
      - uses: actions/checkout@v4
      - id: detect
        run: |
          if [ -f "package.json" ]; then echo "stack=node" >> $GITHUB_OUTPUT
          elif [ -f "requirements.txt" ]; then echo "stack=python" >> $GITHUB_OUTPUT
          else echo "stack=unknown" >> $GITHUB_OUTPUT
          fi
```

### 3.2 Reusable workflow entry point
In `pipeline-toolkit/.github/workflows/pipeline.yml`:
```yaml
on:
  workflow_call:
    inputs:
      deploy_target:
        type: string
        default: docker    # or 'k8s'
      severity_gate:
        type: string
        default: HIGH
```
Each project's own workflow file becomes almost nothing:
```yaml
# in POS repo: .github/workflows/ci.yml
on: [push, pull_request]
jobs:
  pipeline:
    uses: your-username/pipeline-toolkit/.github/workflows/pipeline.yml@main
    with:
      deploy_target: k8s
      severity_gate: HIGH
    secrets: inherit
```

### 3.3 Test, dependency scan, secret scan (parallel jobs)
Covered in the earlier guide — Trivy for dependency/image CVEs, Gitleaks for secrets, standard test/lint job. These three run with no `needs:` between them so they execute in parallel, keeping the pipeline fast.

### 3.4 Docker build with multi-stage image
Standard multi-stage Dockerfile (see earlier guide, section 5), tagged with the commit SHA so every build is traceable:
```yaml
- run: docker build -t ghcr.io/${{ github.repository }}:${{ github.sha }} .
- run: docker push ghcr.io/${{ github.repository }}:${{ github.sha }}
```
Using **GitHub Container Registry (ghcr.io)** keeps this free and tied to your GitHub account — no separate Docker Hub billing to worry about.

### 3.5 Two deploy targets, one config switch
- **`deploy_target: docker`** → SSH into a VPS, `docker compose pull && docker compose up -d`
- **`deploy_target: k8s`** → `helm upgrade --install app ./chart --set image.tag=${{ github.sha }}`

Write **one generic Helm chart** (`chart/`) with `values.yaml` parameterizing image name/tag, replica count, resource limits, and ingress host. Every project reuses the same chart — you just override values per-repo.

### 3.6 Staging vs prod environments
- Push to `develop` → auto-deploys to a `staging` namespace (k8s) or a separate staging compose stack — no approval needed, fast feedback loop.
- Push to `main` → uses **GitHub Environments** with a required reviewer:
```yaml
  deploy-prod:
    environment: production   # configured in repo settings with required reviewers
    needs: [deploy-staging-smoke-test]
```
This gets you a real "someone has to click approve" gate in the GitHub UI — looks and behaves exactly like enterprise deployment pipelines.

### 3.7 Rollback on failed health check
After deploy, run a smoke test (simple `curl` against a `/health` endpoint). If it fails:
- **k8s**: `helm rollback app` — one command, Helm keeps release history automatically
- **Docker**: keep the previous image tag recorded in a file on the server; on failure, `docker compose up -d` with that tag instead

```yaml
- name: Health check
  run: |
    sleep 10
    curl -f https://your-app/health || echo "FAILED" > healthcheck_failed
- name: Rollback on failure
  if: failure()
  run: helm rollback app
```

---

## 4. Stretch tier (add in this order if you have time)

Ranked by impact-per-effort, based on what we discussed:

1. **Canary rollout (10% → 100%)** — for k8s this is mostly configuration:
   ```yaml
   strategy:
     rollingUpdate:
       maxSurge: 10%
       maxUnavailable: 0
   ```
   Combine with the health check step above: deploy, wait, check, then scale to 100% or roll back. This single addition makes your demo genuinely look like a real company's deploy process.

2. **SARIF scan reports in GitHub Security tab** — Trivy and Gitleaks can both output SARIF format:
   ```yaml
   - uses: aquasecurity/trivy-action@master
     with:
       format: 'sarif'
       output: 'trivy-results.sarif'
   - uses: github/codeql-action/upload-sarif@v3
     with:
       sarif_file: 'trivy-results.sarif'
   ```
   Now vulnerability history shows up natively in GitHub's UI — a nice screen-share moment in an interview.

3. **Pluggable config per project** (`pipeline.yml` in each repo):
   ```yaml
   scanners: [trivy, gitleaks]
   severity_gate: HIGH
   deploy_target: k8s
   canary: true
   ```
   This is what makes the "universal" claim provable — different repos, different configs, same underlying toolkit.

4. **Terraform for environment provisioning** — even a minimal Terraform config that spins up your VPS or a `kind`/`k3s` cluster from scratch. Doesn't need to be elaborate; the point is "not manually clicked together."

5. **Status dashboard** — a static page (could literally be a GitHub Pages site generated by the pipeline) showing last deploy time, pass/fail, and scan results per project. This is the single best "demo in 30 seconds" artifact — screen-share this instead of scrolling through Actions logs.

6. **Basic observability** — Prometheus + Grafana Helm charts pointed at your deployed app, or even just structured JSON logs shipped to a free log aggregator. Optional, but rounds out the "production-minded" story if you have bandwidth.

---

## 5. Suggested build order (realistic, solo, alongside job hunting)

**Week 1 — Core pipeline, Docker only**
Stack detection → test/lint → Trivy dep scan → Gitleaks → Docker build+push → manual VPS deploy via SSH. Get this green end-to-end on the POS repo.

**Week 2 — Make it reusable + add Kubernetes**
Move the workflow into its own `pipeline-toolkit` repo as a `workflow_call`. Write the generic Helm chart. Set up a free `k3s`/`kind` cluster. Get k8s deploy working as the second `deploy_target` option.

**Week 3 — Environments + safety**
Staging/prod split with GitHub Environments approval gate. Health-check-based rollback (Helm rollback is nearly free once you're on k8s).

**Week 4 — Polish for demo**
Pick 2–3 stretch items: SARIF reports (easy, high visual payoff) + status dashboard (best demo value) are the strongest ROI. Canary rollout if you have the time — it's the most "wow" feature per line of config.

Stop there. A working core + 2–3 stretch features, cleanly documented, beats a half-finished version of everything.

---

## 6. README structure for the finished project

```
# pipeline-toolkit

One-paragraph pitch (reusable, stack-agnostic, Docker + K8s, security-gated)

## Architecture
[diagram from section 1]

## Supported stacks
Node.js, Python (extensible — detection logic in detect job)

## Features
- Parallel test/dependency-scan/secret-scan
- Docker + Kubernetes/Helm deploy targets (config-switchable)
- Staging → production promotion with approval gate
- Automatic rollback on failed health check
- [any stretch features you completed]

## Usage
How another repo plugs into this (the 5-line workflow_call example)

## Adopted by
Links to POS System, Burger, ClimbingTribe repos using this pipeline

## Local development
docker compose up / kind cluster setup instructions
```

**Resume line once finished:**
> *"Designed and built a reusable, stack-agnostic DevSecOps pipeline (GitHub Actions) supporting Docker and Kubernetes deployment targets with staged environments, automated vulnerability/secret gating, and health-check-triggered rollback — adopted across 3 personal full-stack projects."*
