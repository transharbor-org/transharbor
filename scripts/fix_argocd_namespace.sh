#!/bin/bash
# Fix ArgoCD namespace duplication
# ArgoCD should only run in the 'argocd' namespace, not 'default'

set -e

echo "🔍 Checking for ArgoCD installations..."

# Check if ArgoCD exists in default namespace
if kubectl get deployment -n default argocd-application-controller 2>/dev/null; then
    echo "⚠️  Found ArgoCD in 'default' namespace - this should not be here"
    echo "📋 ArgoCD pods in default namespace:"
    kubectl get pods -n default | grep argocd || true
    
    read -p "Remove ArgoCD from 'default' namespace? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🗑️  Removing ArgoCD from default namespace..."
        
        # Delete ArgoCD resources in default namespace
        kubectl delete deployment -n default argocd-application-controller --ignore-not-found=true
        kubectl delete deployment -n default argocd-applicationset-controller --ignore-not-found=true
        kubectl delete deployment -n default argocd-redis --ignore-not-found=true
        kubectl delete deployment -n default argocd-repo-server --ignore-not-found=true
        kubectl delete statefulset -n default argocd-application-controller --ignore-not-found=true
        
        # Delete services
        kubectl delete service -n default argocd-application-controller --ignore-not-found=true
        kubectl delete service -n default argocd-applicationset-controller --ignore-not-found=true
        kubectl delete service -n default argocd-redis --ignore-not-found=true
        kubectl delete service -n default argocd-repo-server --ignore-not-found=true
        kubectl delete service -n default argocd-server --ignore-not-found=true
        
        # Delete configmaps and secrets
        kubectl delete configmap -n default -l app.kubernetes.io/part-of=argocd --ignore-not-found=true
        kubectl delete secret -n default -l app.kubernetes.io/part-of=argocd --ignore-not-found=true
        
        echo "✅ ArgoCD removed from default namespace"
    fi
fi

# Check ArgoCD in argocd namespace
if kubectl get namespace argocd 2>/dev/null; then
    echo "✅ ArgoCD namespace exists"
    echo "📋 ArgoCD pods in argocd namespace:"
    kubectl get pods -n argocd | grep argocd || true
    
    # Check health
    if kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server --no-headers 2>/dev/null | grep -q Running; then
        echo "✅ ArgoCD is running in correct namespace"
    else
        echo "⚠️  ArgoCD server not running in argocd namespace"
    fi
else
    echo "❌ ArgoCD namespace does not exist!"
    echo "Run: kubectl create namespace argocd"
    echo "Then: kubectl apply -n argocd -f iaac/argocd/install.yaml"
fi

echo ""
echo "📊 Final state:"
echo "Default namespace ArgoCD pods:"
kubectl get pods -n default | grep argocd || echo "  None (✅ correct)"
echo ""
echo "ArgoCD namespace pods:"
kubectl get pods -n argocd | grep argocd || echo "  None"
