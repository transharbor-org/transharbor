#!/bin/bash
# Configure ArgoCD for faster syncs (30 second polling)
# This reduces deployment time from 3 minutes to 30 seconds

set -e

echo "🔧 Configuring ArgoCD for faster deployment sync..."

# Set reconciliation interval to 30 seconds
kubectl patch configmap argocd-cm -n argocd --type merge -p='{
  "data": {
    "timeout.reconciliation": "30s",
    "application.resourceTrackingMethod": "annotation"
  }
}'

# Configure the application controller for faster polling
kubectl set env deployment/argocd-application-controller \
  -n argocd \
  ARGOCD_RECONCILIATION_TIMEOUT=30s

# Restart the controller to apply changes
echo "♻️  Restarting ArgoCD application controller..."
kubectl rollout restart deployment argocd-application-controller -n argocd

# Wait for rollout to complete
echo "⏳ Waiting for controller to restart..."
kubectl rollout status deployment argocd-application-controller -n argocd --timeout=60s

echo "✅ ArgoCD configured for 30-second sync interval"
echo ""
echo "📊 Deployment times:"
echo "   - Previous: ~3 minutes (default 180s polling)"
echo "   - Now: ~30-60 seconds (30s polling + sync time)"
echo ""
echo "💡 To verify: kubectl describe application transharbor-dev -n argocd"
