#!/bin/bash
set -e

echo "Migrating to ArgoCD Core (minimal installation)"
echo "This will save ~150MB RAM by removing UI, SSO, notifications, and applicationset controllers"
echo ""

# Backup current applications
echo "Backing up current ArgoCD applications..."
kubectl get applications -n argocd -o yaml > argocd-applications-backup.yaml
echo "✓ Applications backed up to argocd-applications-backup.yaml"

# Delete old ArgoCD
echo ""
echo "Removing full ArgoCD installation..."
kubectl delete namespace argocd --wait=true
echo "✓ ArgoCD removed"

# Install ArgoCD Core
echo ""
echo "Installing ArgoCD Core..."
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/core-install.yaml
echo "✓ ArgoCD Core installed"

# Wait for pods
echo ""
echo "Waiting for ArgoCD Core pods to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-application-controller -n argocd --timeout=300s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-repo-server -n argocd --timeout=300s
echo "✓ ArgoCD Core is ready"

# Restore applications
echo ""
echo "Restoring applications..."
kubectl apply -f argocd-applications-backup.yaml
echo "✓ Applications restored"

# Show status
echo ""
echo "ArgoCD Core Status:"
kubectl get pods -n argocd
echo ""
kubectl top pods -n argocd
echo ""
echo "✓ Migration complete!"
echo ""
echo "Memory savings: ~150MB"
echo "Manage apps via kubectl: kubectl get applications -n argocd"
echo "Trigger sync: kubectl patch application <name> -n argocd --type merge -p '{\"operation\":{\"sync\":{}}}'"
