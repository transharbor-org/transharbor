#!/bin/bash
# Remove metrics-server now that we have Prometheus for metrics
# Saves ~28MB RAM

set -e

echo "🗑️  Removing metrics-server (replaced by Prometheus)..."
echo ""

# Check if metrics-server exists
if kubectl get deployment metrics-server -n kube-system >/dev/null 2>&1; then
    echo "📊 Current metrics-server status:"
    kubectl top deployment metrics-server -n kube-system 2>/dev/null || echo "   (metrics not available yet)"
    echo ""
    
    echo "🔄 Deleting metrics-server deployment..."
    kubectl delete deployment metrics-server -n kube-system
    
    echo "🔄 Deleting metrics-server service..."
    kubectl delete service metrics-server -n kube-system
    
    echo "🔄 Deleting metrics-server ServiceAccount..."
    kubectl delete serviceaccount metrics-server -n kube-system 2>/dev/null || true
    
    echo "🔄 Deleting metrics-server ClusterRole..."
    kubectl delete clusterrole system:metrics-server 2>/dev/null || true
    
    echo "🔄 Deleting metrics-server ClusterRoleBinding..."
    kubectl delete clusterrolebinding system:metrics-server 2>/dev/null || true
    
    echo ""
    echo "✅ metrics-server removed successfully!"
    echo ""
    echo "⚠️  Note: kubectl top will no longer work"
    echo "   Use Grafana dashboards for metrics instead:"
    echo "   https://dev.transharbor.org/grafana"
    echo ""
    echo "💾 RAM saved: ~28MB"
else
    echo "ℹ️  metrics-server not found (already removed or never installed)"
fi

echo ""
echo "🔍 Verifying Prometheus is running..."
if kubectl get deployment prometheus -n observability >/dev/null 2>&1; then
    echo "✅ Prometheus is running"
    kubectl get pods -n observability -l app=prometheus
else
    echo "⚠️  Prometheus not found!"
    echo "   Deploy observability stack first: kubectl apply -f iaac/observability/"
fi

echo ""
echo "🎉 Done! Use Prometheus/Grafana for all metrics going forward."
