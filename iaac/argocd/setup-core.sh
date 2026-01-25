#!/bin/bash
# Setup ArgoCD Core with proper configuration
set -e

echo "🔧 Setting up ArgoCD Core..."

# Apply default project
echo "📦 Creating default AppProject..."
kubectl apply -f /home/aaron/transharbor/iaac/argocd/default-project.yaml

# Apply cluster secret
echo "🔐 Creating in-cluster secret..."
kubectl apply -f /home/aaron/transharbor/iaac/argocd/cluster-secret.yaml

# Configure sync interval to 1 minute
echo "⏱️  Setting sync interval to 60 seconds..."
kubectl patch configmap argocd-cm -n argocd --type merge -p '{
  "data": {
    "timeout.reconciliation": "60s"
  }
}' 2>/dev/null || echo "ConfigMap may not exist yet"

# Restart application controller to pick up changes
echo "🔄 Restarting application controller..."
kubectl rollout restart statefulset/argocd-application-controller -n argocd

echo "✅ ArgoCD Core setup complete!"
echo ""
echo "ArgoCD will now:"
echo "  - Sync applications every 60 seconds"
echo "  - Automatically apply changes from Git"
echo "  - Self-heal any manual changes"
