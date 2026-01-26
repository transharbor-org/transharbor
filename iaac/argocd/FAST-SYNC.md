# ArgoCD Fast Sync Configuration

## Problem
ArgoCD Core polls GitHub every **3 minutes** by default, causing slow deployments.

## Solution
Reduce polling interval to **30 seconds** for near-instant deployments.

## Setup

Run the configuration script on your Kubernetes cluster:

```bash
bash iaac/argocd/configure-fast-sync.sh
```

This will:
1. Set ArgoCD reconciliation timeout to 30s
2. Configure the application controller
3. Restart the controller to apply changes

## Result
- **Before:** ~3 minute deployment delay
- **After:** ~30-60 second deployment delay

## Why Not Webhooks?

You're using **ArgoCD Core** (no API server/UI) to save memory (~150MB RAM). 
Webhooks require the full ArgoCD installation with API server.

**Options:**
1. **Current approach** (30s polling) - Best balance of speed vs resources
2. **Full ArgoCD + webhooks** - Instant sync but uses more memory
3. **Manual sync in CI** - Guaranteed immediate deployment

## Manual Sync (Alternative)

If you need instant deployment, add this to your CI/CD after pushing images:

```bash
kubectl patch application transharbor-dev -n argocd \
  --type merge \
  -p '{"operation":{"sync":{}}}'
```

## Verify Configuration

```bash
# Check current settings
kubectl describe configmap argocd-cm -n argocd

# Watch for sync activity
kubectl logs -f deployment/argocd-application-controller -n argocd

# Check application status
kubectl describe application transharbor-dev -n argocd
```
