#!/bin/bash
# Optimize ArgoCD for minimal resource usage
# Run this on the k3s cluster after migration to ArgoCD Core

set -e

echo "Optimizing ArgoCD Core configuration..."

# Reduce repo-server replicas to 1 (we have a single repo)
kubectl scale deployment argocd-repo-server -n argocd --replicas=1

# Add resource limits to argocd-repo-server (heaviest component)
kubectl patch deployment argocd-repo-server -n argocd --type json -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/resources",
    "value": {
      "requests": {
        "cpu": "50m",
        "memory": "64Mi"
      },
      "limits": {
        "cpu": "200m",
        "memory": "128Mi"
      }
    }
  }
]'

# Add resource limits to argocd-application-controller
kubectl patch deployment argocd-application-controller -n argocd --type json -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/resources",
    "value": {
      "requests": {
        "cpu": "50m",
        "memory": "64Mi"
      },
      "limits": {
        "cpu": "200m",
        "memory": "128Mi"
      }
    }
  }
]'

# Optimize application-controller for single repo
kubectl patch configmap argocd-cmd-params-cm -n argocd --type merge -p='{
  "data": {
    "repo.server.parallelism.limit": "1",
    "controller.status.processors": "5",
    "controller.operation.processors": "5"
  }
}'

# Increase sync timeout for Flutter builds (large assets)
kubectl patch configmap argocd-cm -n argocd --type merge -p='{
  "data": {
    "timeout.reconciliation": "180s"
  }
}'

# Restart ArgoCD components to apply changes
kubectl rollout restart deployment argocd-repo-server -n argocd
kubectl rollout restart deployment argocd-application-controller -n argocd

echo "Waiting for rollout to complete..."
kubectl rollout status deployment argocd-repo-server -n argocd --timeout=120s
kubectl rollout status deployment argocd-application-controller -n argocd --timeout=120s

echo "ArgoCD optimization complete!"
echo
echo "Expected resource usage:"
echo "  argocd-repo-server: ~30-50Mi (was ~100Mi)"
echo "  argocd-application-controller: ~40-60Mi (was ~124Mi)"
echo "  Total ArgoCD: ~70-110Mi (was ~224Mi)"
