# TransHarbor Observability Stack

Minimal observability infrastructure for monitoring and logging TransHarbor applications.

## Components

### 1. **Metrics Server** ✅ Already Running
- Built-in Kubernetes metrics
- Provides `kubectl top` functionality
- CPU and memory metrics for nodes and pods

### 2. **Prometheus** (Metrics Collection)
- Scrapes metrics from Kubernetes API, nodes, and pods
- 7-day retention
- Minimal resource usage (256Mi RAM)
- Auto-discovers pods with `prometheus.io/scrape: "true"` annotation

### 3. **Grafana** (Visualization)
- Web UI for metrics and logs
- Pre-configured Prometheus and Loki datasources
- Access: https://dev.transharbor.org/grafana
- Default credentials: `admin` / `changeme-dev-password`

### 4. **Loki** (Log Aggregation)
- Lightweight log aggregation system
- 7-day log retention
- Indexes logs from all pods
- Query logs via Grafana

### 5. **Promtail** (Log Collector)
- DaemonSet running on each node
- Collects logs from all containers
- Ships logs to Loki

## Deployment

```bash
# Deploy observability stack
kubectl apply -f iaac/observability/

# Check status
kubectl get pods -n observability

# Access Grafana
open https://dev.transharbor.org/grafana

# Access Prometheus
open https://dev.transharbor.org/prometheus
```

## Resource Usage

Total minimal footprint:
- **Prometheus**: 100m CPU, 256Mi RAM
- **Grafana**: 100m CPU, 128Mi RAM
- **Loki**: 100m CPU, 128Mi RAM
- **Promtail**: 50m CPU, 64Mi RAM (per node)
- **Total**: ~350m CPU, ~512Mi RAM

## Features

### Prometheus Metrics
- Kubernetes API server metrics
- Node resource usage (CPU, memory, disk)
- Pod metrics (all namespaces)
- Traefik ingress metrics
- Custom application metrics (if pods expose `/metrics`)

### Loki Logs
- All container stdout/stderr logs
- Searchable by namespace, pod, container
- 7-day retention
- LogQL query language

### Grafana Dashboards
After deployment, import community dashboards:
- **Kubernetes Cluster**: Dashboard ID 7249
- **Node Exporter**: Dashboard ID 1860
- **Traefik**: Dashboard ID 11462
- **Loki Logs**: Built-in explore view

## Annotations for Application Monitoring

Add to your pod/deployment to expose metrics:

```yaml
metadata:
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "8080"
    prometheus.io/path: "/metrics"
```

## Queries

### Prometheus Examples
```promql
# CPU usage by pod
sum(rate(container_cpu_usage_seconds_total[5m])) by (pod)

# Memory usage by namespace
sum(container_memory_usage_bytes) by (namespace)

# HTTP request rate
rate(http_requests_total[5m])
```

### Loki Examples
```logql
# All logs from transharbor namespace
{namespace="transharbor"}

# Errors in pocketbase
{namespace="transharbor", pod=~"pocketbase.*"} |= "error"

# Web app logs
{namespace="transharbor", pod=~"web.*"}
```

## Upgrading

```bash
# Update configurations
kubectl apply -f iaac/observability/

# Restart components
kubectl rollout restart deployment/prometheus -n observability
kubectl rollout restart deployment/grafana -n observability
kubectl rollout restart deployment/loki -n observability
kubectl rollout restart daemonset/promtail -n observability
```

## Troubleshooting

```bash
# Check Prometheus targets
kubectl port-forward -n observability svc/prometheus 9090:9090
# Open http://localhost:9090/targets

# Check Loki ingestion
kubectl logs -n observability deployment/loki

# Check Promtail collection
kubectl logs -n observability daemonset/promtail

# Test log query
curl http://localhost:3100/loki/api/v1/query?query={namespace="transharbor"}
```

## Security Notes

- Grafana anonymous viewing enabled for development
- Change admin password in production
- Consider adding authentication to Prometheus endpoint
- Logs may contain sensitive data - review retention policy
