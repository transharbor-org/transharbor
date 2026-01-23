# Resource Optimization Guide

## Quick Wins (Total savings: ~170MB on 2GB node)

### 1. **Migrate to ArgoCD Core** (~150MB savings)
```bash
ssh root@dev.transharbor.org
./iaac/argocd/migrate-to-core.sh
```

### 2. **Remove cert-manager, use Traefik ACME** (~70MB savings)
```bash
# Apply Traefik config with ACME
kubectl apply -f iaac/common/traefik-config.yaml

# Update ingresses to use Traefik cert resolver
# Then remove cert-manager
kubectl delete namespace cert-manager
```

### 3. **Remove metrics-server** (~28MB savings)
```bash
kubectl delete deployment metrics-server -n kube-system
# Note: kubectl top will no longer work
```

### 4. **Apply optimized resource limits** (better packing)
Current manifests now use:
- Requests: 50m CPU, 32Mi RAM (packed tightly)
- Limits: 500m CPU, 128Mi RAM (burst capacity)
- Health probes: Startup, readiness, liveness
- Graceful shutdown: PreStop hooks

### 5. **Pod Priority Classes** (resilience)
```bash
kubectl apply -f iaac/common/priority-classes.yaml
```
- PocketBase: high-priority (survives eviction)
- Web: medium-priority (default)

## Resource Comparison

### Before optimization:
- ArgoCD (full): 224MB
- cert-manager: 73MB  
- metrics-server: 28MB
- Web (2x512MB limits): 1024MB reserved
- PocketBase (512MB limit): 512MB reserved
- **Total reserved: 1861MB (93% of 2GB)**

### After optimization:
- ArgoCD Core: 70MB
- Traefik (with ACME): 31MB
- Web (2x128MB limits): 256MB reserved
- PocketBase (128MB limit): 128MB reserved
- **Total reserved: 485MB (24% of 2GB)**

### Memory available for bursts: **~1.5GB**

## Advanced Optimizations

### 6. **Reduce ArgoCD sync interval** (save CPU)
```bash
# In argocd-cm ConfigMap
timeout.reconciliation: 600  # 10 minutes instead of 3
```

### 7. **Disable unused k3s features**
Edit `/etc/systemd/system/k3s.service`:
```
--disable=traefik  # if using external LB
--disable=local-storage  # if using external storage
--kube-apiserver-arg=enable-admission-plugins=NodeRestriction  # remove extras
```

### 8. **Use node taints to reserve capacity**
```bash
# Prevent new pods from being scheduled
kubectl taint nodes dev.transharbor.org reserved=true:NoSchedule
# Remove taint when needed
kubectl taint nodes dev.transharbor.org reserved:NoSchedule-
```

## Monitoring (without metrics-server)

### Check resource usage:
```bash
# Node resources
free -h
top -bn1 | head -n 20

# Pod memory (via cgroup)
kubectl get pods -A -o jsonpath='{range .items[*]}{.metadata.namespace}/{.metadata.name}: {.spec.containers[*].resources.requests.memory}{"\n"}{end}'

# k3s process memory
ps aux | grep k3s
```

### Setup lightweight monitoring:
```bash
# Install node-exporter as DaemonSet (8MB)
# Use external Prometheus/Grafana for visualization
```

## For Production (Civo K8s)

Don't over-optimize production:
- Use full ArgoCD with UI
- Keep metrics-server for HPA
- Use managed cert-manager or external secrets
- Monitor with Prometheus stack
- Size nodes appropriately (4GB+ RAM)

## Emergency: Out of Memory

If node hits OOM:
```bash
# Check what's using memory
kubectl top pods -A --sort-by=memory

# Evict low-priority pods first
kubectl delete pod -l priority=low

# Reduce replicas temporarily
kubectl scale deployment web-dev -n transharbor --replicas=1

# Restart k3s to clear caches
systemctl restart k3s
```
