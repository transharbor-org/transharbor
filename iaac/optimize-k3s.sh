#!/bin/bash
# Optimize k3s for minimal resource usage
# Run on dev.transharbor.org

echo "K3s resource optimization script"
echo "================================="
echo ""

# 1. Remove metrics-server (saves ~28MB)
echo "1. Removing metrics-server (saves ~28MB RAM)..."
kubectl delete deployment metrics-server -n kube-system
kubectl delete service metrics-server -n kube-system
echo "   Note: kubectl top will no longer work"
echo ""

# 2. Disable Traefik dashboard (minimal savings but removes attack surface)
echo "2. Disabling Traefik dashboard..."
kubectl patch deployment traefik -n kube-system --type='json' \
  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--api.dashboard=false"}]'
echo ""

# 3. Remove cert-manager (saves ~70MB) - only if using Traefik ACME
read -p "3. Remove cert-manager? (saves ~70MB, requires Traefik ACME setup) [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    kubectl delete namespace cert-manager
    echo "   ✓ cert-manager removed"
    echo "   ! Configure Traefik ACME before removing ingress annotations"
fi
echo ""

# 4. Reduce ArgoCD resource requests (if using full ArgoCD)
echo "4. Checking ArgoCD installation..."
if kubectl get namespace argocd >/dev/null 2>&1; then
    if kubectl get deployment argocd-server -n argocd >/dev/null 2>&1; then
        echo "   Full ArgoCD detected. Consider migrating to ArgoCD Core."
        echo "   Run: iaac/argocd/migrate-to-core.sh"
    else
        echo "   ✓ ArgoCD Core already installed"
    fi
fi
echo ""

# 5. Show current resource usage
echo "Current resource usage:"
echo "======================"
kubectl top nodes
echo ""
echo "Pod memory usage by namespace:"
kubectl top pods -A --no-headers | awk '{ns[$1]+=$4} END {for (i in ns) print i, ns[i]"Mi"}' | sort -k2 -rn
echo ""

echo "Optimization complete!"
echo ""
echo "Expected savings:"
echo "- metrics-server: ~28MB"
echo "- cert-manager: ~70MB (if removed)"
echo "- Total potential: ~98MB"
