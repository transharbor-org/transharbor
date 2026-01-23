# GitOps with ArgoCD

This repository uses GitOps principles with ArgoCD for continuous deployment across all environments.

## Overview

GitOps uses Git as the single source of truth for declarative infrastructure and applications. When you push changes to this repository, ArgoCD automatically syncs them to your Kubernetes cluster.

## Architecture

```
GitHub Repository (Source of Truth)
        ↓
    ArgoCD (Watches Repository)
        ↓
   K3s Cluster (Deployment Target)
```

### Components

- **GitHub Actions**: Builds and pushes Docker images to GitHub Container Registry (GHCR)
- **ArgoCD**: Monitors this repository and automatically deploys changes to k3s
- **GHCR**: Hosts container images at `ghcr.io/transharbor-org/transharbor/{web,pocketbase}`

## Setup

### 1. Install ArgoCD

```bash
# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
```

### 2. Access ArgoCD UI

```bash
# Port forward to access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo

# Login
# Username: admin
# Password: (from above command)
# URL: https://localhost:8080
```

### 3. Install cert-manager (for Let's Encrypt)

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
```

### 4. Deploy Applications

Deploy the common resources and environments:

```bash
# Deploy common resources (namespace, cert-issuer)
kubectl apply -f iaac/argocd/application-common.yaml

# Deploy dev environment
kubectl apply -f iaac/argocd/application-dev.yaml

# Deploy stage environment
kubectl apply -f iaac/argocd/application-stage.yaml

# Deploy production environment (requires manual sync)
kubectl apply -f iaac/argocd/application-app.yaml
```

### 5. Configure GitHub Container Registry Access

If your repository is private, you need to add image pull secrets:

```bash
# Create docker-registry secret
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=<github-username> \
  --docker-password=<github-token> \
  --namespace=transharbor

# Add imagePullSecrets to deployments (already configured in manifests)
```

## Deployment Flow

### Automatic (Dev & Stage)

1. Developer pushes code to `main` branch
2. GitHub Actions workflow runs:
   - Runs tests and linting
   - Builds Docker images for web and pocketbase
   - Pushes images to GHCR with tags: `main`, `main-<sha>`
3. ArgoCD detects the change in Git
4. ArgoCD automatically syncs to dev and stage environments
5. New pods are rolled out with the updated images

### Manual (Production)

Production deployments require manual approval for safety:

1. Verify changes in stage environment
2. Use ArgoCD UI or CLI to manually sync the production application
3. Monitor the rollout

```bash
# Sync production via CLI
argocd app sync transharbor-app
```

## Managing Secrets

Secrets are stored in the repository as templates. Before deploying, update them:

```bash
# Update secrets for each environment
kubectl create secret generic pocketbase-admin-dev \
  --from-literal=password='<strong-password>' \
  --namespace=transharbor \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic pocketbase-admin-stage \
  --from-literal=password='<strong-password>' \
  --namespace=transharbor \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic pocketbase-admin-app \
  --from-literal=password='<strong-password>' \
  --namespace=transharbor \
  --dry-run=client -o yaml | kubectl apply -f -
```

**Better approach**: Use [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets) or external secret management.

## Monitoring Deployments

### ArgoCD UI

Access at `https://localhost:8080` (when port-forwarded) to see:
- Application health and sync status
- Resource tree view
- Deployment history
- Live logs

### ArgoCD CLI

```bash
# Install ArgoCD CLI
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/local/bin/argocd

# Login
argocd login localhost:8080

# List applications
argocd app list

# Get application details
argocd app get transharbor-dev

# View logs
argocd app logs transharbor-dev

# Force sync
argocd app sync transharbor-dev
```

### Kubectl

```bash
# Check application status
kubectl get applications -n argocd

# Check pods
kubectl get pods -n transharbor

# View logs
kubectl logs -n transharbor -l app=web,env=dev
kubectl logs -n transharbor -l app=pocketbase,env=dev
```

## Rollback

If a deployment fails, you can easily rollback:

### Via ArgoCD UI
1. Open the application
2. Click "History and Rollback"
3. Select a previous revision
4. Click "Rollback"

### Via CLI
```bash
# View history
argocd app history transharbor-dev

# Rollback to specific revision
argocd app rollback transharbor-dev <revision-id>
```

### Via Git
```bash
# Revert the commit
git revert <commit-sha>
git push

# ArgoCD will automatically sync the reverted state
```

## Image Tags

Images are tagged with:
- `main` - Latest build from main branch (moves with each build)
- `main-<sha>` - Specific commit SHA (immutable)

For production stability, consider pinning to SHA tags in manifests instead of `main`.

## Troubleshooting

### Application Out of Sync
```bash
# Check diff
argocd app diff transharbor-dev

# Force sync
argocd app sync transharbor-dev --force
```

### Image Pull Errors
```bash
# Check if secret exists
kubectl get secret ghcr-secret -n transharbor

# Verify secret is referenced in deployment
kubectl get deployment web-dev -n transharbor -o yaml | grep imagePullSecrets
```

### Pods Not Starting
```bash
# Check pod status
kubectl get pods -n transharbor

# View pod logs
kubectl logs -n transharbor <pod-name>

# Describe pod for events
kubectl describe pod -n transharbor <pod-name>
```

### Certificate Issues
```bash
# Check certificate status
kubectl get certificate -n transharbor

# Check cert-manager logs
kubectl logs -n cert-manager -l app=cert-manager
```

## Best Practices

1. **Never commit sensitive data**: Use secrets management tools
2. **Use immutable tags**: Pin production to SHA tags, not `latest` or `main`
3. **Test in dev/stage first**: Always validate changes before production
4. **Monitor closely**: Watch ArgoCD and pod logs during deployments
5. **Keep manifests DRY**: Use Kustomize or Helm for shared configurations
6. **Document changes**: Use clear commit messages for audit trail
7. **Enable notifications**: Configure ArgoCD to notify on Slack/email

## Resources

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [GitOps Principles](https://opengitops.dev/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
