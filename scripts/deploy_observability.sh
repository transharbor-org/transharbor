#!/bin/bash
# Deploy TransHarbor Observability Stack

set -e

echo "🔭 Deploying TransHarbor Observability Stack"
echo "============================================"

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found. Please install kubectl."
    exit 1
fi

# Deploy namespace
echo "📦 Creating observability namespace..."
kubectl apply -f iaac/observability/namespace.yaml

# Deploy Prometheus
echo "📊 Deploying Prometheus..."
kubectl apply -f iaac/observability/prometheus.yaml

# Deploy Loki
echo "📝 Deploying Loki and Promtail..."
kubectl apply -f iaac/observability/loki.yaml

# Deploy Grafana
echo "📈 Deploying Grafana..."
kubectl apply -f iaac/observability/grafana.yaml

# Deploy Ingress routes
echo "🌐 Configuring Traefik ingress..."
kubectl apply -f iaac/observability/traefik-ingress.yaml

echo ""
echo "⏳ Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=prometheus -n observability --timeout=120s || true
kubectl wait --for=condition=ready pod -l app=loki -n observability --timeout=120s || true
kubectl wait --for=condition=ready pod -l app=grafana -n observability --timeout=120s || true

echo ""
echo "✅ Observability Stack Deployed!"
echo ""
echo "📊 Status:"
kubectl get pods -n observability

echo ""
echo "🌐 Access URLs:"
echo "  Grafana:    https://dev.transharbor.org/grafana"
echo "  Prometheus: https://dev.transharbor.org/prometheus"
echo ""
echo "🔑 Grafana Credentials:"
echo "  Username: admin"
echo "  Password: changeme-dev-password"
echo ""
echo "📝 To view logs:"
echo "  kubectl logs -n observability deployment/prometheus"
echo "  kubectl logs -n observability deployment/loki"
echo "  kubectl logs -n observability deployment/grafana"
echo ""
echo "🔍 Check metrics server:"
echo "  kubectl top nodes"
echo "  kubectl top pods -n transharbor"
