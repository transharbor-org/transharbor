# TransHarbor Infrastructure

This directory contains Kubernetes (k3s) configurations for deploying TransHarbor across multiple environments using GitOps principles.

## Quick Links

- **[GitOps Setup Guide](./GITOPS.md)** - Complete ArgoCD setup and deployment workflow
- **[ArgoCD Applications](./argocd/)** - Application manifests for each environment

## Environments

- **dev**: Development environment at `dev.transharbor.org`
- **stage**: Staging environment at `stage.transharbor.org`
- **app**: Production environment at `app.transharbor.org`

## Architecture

Each environment runs on k3s with:
- 1 vCPU
- 1 GB RAM
- PocketBase backend
- Flutter web UI
- Let's Encrypt SSL certificates
- Support for iOS and Android apps

### GitOps Flow

```
Developer Push → GitHub Actions → Build Images → GHCR
                       ↓
                   ArgoCD watches repo
                       ↓
              Auto-sync to k3s cluster
```

## Quick Start

### Option 1: GitOps (Recommended)

See [GITOPS.md](./GITOPS.md) for complete setup instructions.

```bash
# 1. Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 2. Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# 3. Deploy applications
kubectl apply -f iaac/argocd/application-common.yaml
kubectl apply -f iaac/argocd/application-dev.yaml
kubectl apply -f iaac/argocd/application-stage.yaml
kubectl apply -f iaac/argocd/application-app.yaml
```

### Option 2: Manual Deployment

### Prerequisites

1. k3s installed on each node
2. kubectl configured
3. cert-manager installed for Let's Encrypt

### Install cert-manager

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
```

### Deploy an environment

```bash
# Deploy to dev
kubectl apply -f iaac/common/
kubectl apply -f iaac/dev/

# Deploy to stage
kubectl apply -f iaac/common/
kubectl apply -f iaac/stage/

# Deploy to production
kubectl apply -f iaac/common/
kubectl apply -f iaac/app/
```

## Services

### PocketBase
- Persistent data storage
- API backend for Flutter apps
- Admin UI at `/admin`

### Web UI
- Flutter web application
- Served via Nginx
- Supports iOS and Android apps via API

## Subdomain Structure

- `dev.transharbor.org` - Development
- `stage.transharbor.org` - Staging
- `app.transharbor.org` - Production

All subdomains support HTTPS via Let's Encrypt.
