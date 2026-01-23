# Resource Optimization Guide

## Overview
This guide contains optimizations to run Transharbor on minimal resources (2GB RAM, 1 vCPU) while maintaining high availability and zero-downtime deployments.

**Expected resource usage after full optimization:**
- Before: 1861MB reserved (93% of 2GB node)
- After: ~485MB reserved (24% of 2GB node)
- **Savings: 1376MB (68% reduction)**

## Quick Wins (Total savings: ~170MB RAM immediately)

### 1. **Migrate to ArgoCD Core** (~150MB savings)
Removes UI, SSO, notifications, applicationsets. Management via kubectl only.
```bash
ssh root@dev.transharbor.org
cd /root
wget https://raw.githubusercontent.com/transharbor-org/transharbor/main/iaac/argocd/migrate-to-core.sh
chmod +x migrate-to-core.sh
./migrate-to-core.sh

# Then optimize further
wget https://raw.githubusercontent.com/transharbor-org/transharbor/main/iaac/argocd/optimize-core.sh
chmod +x optimize-core.sh
./optimize-core.sh
```

### 2. **Remove cert-manager, use Traefik ACME** (~70MB savings)
Traefik (k3s default) has built-in Let's Encrypt support.
```bash
# Apply Traefik config with ACME
kubectl apply -f iaac/common/traefik-config.yaml

# Update ingresses to use Traefik cert resolver
# Edit iaac/dev/ingress.yaml, remove cert-manager annotations, add:
#   traefik.ingress.kubernetes.io/router.tls.certresolver: letsencrypt

# Then remove cert-manager
kubectl delete namespace cert-manager
```

### 3. **Remove metrics-server** (~28MB savings)
```bash
kubectl delete deployment metrics-server -n kube-system
# Note: kubectl top will no longer work
# Use iaac/monitor.sh for lightweight monitoring instead
```

### 4. **Apply optimized resource limits** (better packing)
Current manifests now use:
- Requests: 50m CPU, 32Mi RAM (matches actual usage)
- Limits: 500m CPU, 128Mi RAM (4x burst capacity)
- Health probes: Startup, readiness, liveness
- Graceful shutdown: PreStop hooks (5s web, 10s PocketBase)
- tmpfs volumes: 32Mi cache, 8Mi run (reduces disk I/O)

### 5. **Pod Priority Classes** (resilience under pressure)
```bash
kubectl apply -f iaac/common/priority-classes.yaml
```
- high-priority (1000): PocketBase survives OOM eviction
- medium-priority (500, default): Web pods
- low-priority (100): Non-essential services

### 6. **Network Policies** (security, minimal overhead)
```bash
kubectl apply -f iaac/common/network-policies.yaml
```
- Restricts traffic between pods (defense in depth)
- Negligible performance impact (~1-2MB RAM)

### 7. **Resource Quotas** (prevent runaway pods)
```bash
kubectl apply -f iaac/common/resource-quotas.yaml
```
- Namespace max: 1.5 CPU, 768Mi requested, 20 pods
- Container defaults: 50m/32Mi, max 1000m/512Mi

## Resource Comparison

### Before optimization:
- ArgoCD (full): 224MB
- cert-manager: 73MB  
- metrics-server: 28MB
- Web (2x512MB limits): 1024MB reserved
- PocketBase (512MB limit): 512MB reserved
- **Total reserved: 1861MB (93% of 2GB node)**
- **Actual usage: ~1492Mi (75%)**

### After optimization:
- ArgoCD Core: ~70MB (with optimize-core.sh)
- Traefik ACME: 0MB (built into Traefik)
- No metrics-server: 0MB
- Web (2x128MB limits): 256MB reserved
- PocketBase (128MB limit): 128MB reserved
- Monitoring: iaac/monitor.sh (0MB, runs externally)
- **Total reserved: ~485MB (24% of 2GB node)**
- **Expected actual usage: ~900Mi (45%)**

**Savings: 1376MB (68% reduction in reserved capacity)**

### After optimization:
- ArgoCD Core: 70MB
- Traefik (with ACME): 31MB
- Web (2x128MB limits): 256MB reserved
- PocketBase (128MB limit): 128MB reserved
- **Total reserved: 485MB (24% of 2GB)**

### Memory available for bursts: **~1.5GB**

## Performance Optimizations

### 8. **Flutter Build Optimization** (faster loads, lower bandwidth)
Configured in `.github/workflows/flutter-ci.yml`:
- `--tree-shake-icons`: Remove unused Material/Cupertino icons (~500KB savings)
- `--pwa-strategy=offline-first`: Better caching
- Pre-compress all assets: `gzip -9 -k` on all JS/CSS/HTML files
- Result: ~30% smaller transfer size, faster first load

### 9. **nginx gzip_static** (lower CPU, faster serving)
Configured in `docker/nginx.conf`:
- `gzip_static on`: Serve pre-compressed .gz files (no runtime compression)
- `gzip_comp_level 6`: Balanced compression for dynamic content
- `gzip_proxied any`: Compress proxied responses
- Result: ~10-20% CPU reduction on high traffic

### 10. **tmpfs volumes** (reduce disk I/O)
Configured in `iaac/dev/web.yaml`:
- `/var/cache/nginx`: 32Mi tmpfs (temporary cache files)
- `/var/run`: 8Mi tmpfs (pid files, sockets)
- Result: Faster I/O, less disk wear, uses RAM instead

### 11. **PocketBase SQLite Optimization**
Run `iaac/optimize-pocketbase.sh` to apply:
- `PRAGMA journal_mode=WAL`: Better concurrency
- `PRAGMA synchronous=NORMAL`: Safe with WAL, much faster
- `PRAGMA cache_size=-4000`: 4MB cache (vs 2MB default)
- `PRAGMA mmap_size=268435456`: Memory-mapped I/O for faster reads
- `PRAGMA temp_store=MEMORY`: Faster temp operations
- Weekly VACUUM via CronJob (iaac/dev/pocketbase-maintenance.yaml)
- Result: ~2-3x faster queries, especially on larger databases

### 12. **Strip PocketBase Binary** (smaller image)
Configured in `docker/Dockerfile.pocketbase`:
- `strip pocketbase`: Remove debug symbols (~2MB savings)
- Result: 20.5MB image → ~18MB

## Security & Stability

### 13. **Network Policies**
```bash
kubectl apply -f iaac/common/network-policies.yaml
```
- Web can only talk to PocketBase
- PocketBase can only receive from Web
- Default deny all other traffic
- Overhead: ~1-2MB RAM, negligible CPU

### 14. **Pod Security Standards**
```bash
kubectl apply -f iaac/common/pod-security.yaml
```
- Enforces baseline security (prevents privilege escalation)
- Warns on restricted violations
- No performance impact

### 15. **Emergency Swap** (OOM protection)
```bash
ssh root@dev.transharbor.org
./iaac/setup-swap.sh 1G
```
- Creates 1GB swap file
- `vm.swappiness=10`: Only swap when critically low
- Result: Node survives temporary spikes, kubelet still evicts low-priority pods first

## Monitoring (Without Prometheus Overhead)

### 16. **Lightweight Monitoring**
```bash
ssh root@dev.transharbor.org
./iaac/monitor.sh transharbor 60
# Logs to /tmp/metrics-transharbor.log every 60 seconds
```
- No persistent storage required
- No Prometheus/Grafana overhead (~200MB saved)
- Simple kubectl top + status checks

## Image Pull Optimization

### 17. **Docker Layer Caching**
See `iaac/IMAGE-PULL-OPTIMIZATION.md` for details:
- Separate COPY layers in Dockerfiles (base → config → app)
- GitHub Actions cache (10GB limit)
- k3s/containerd automatic caching
- Result: 3-5 min builds → 1-2 min, 30-60s pulls → 5-10s

## Automation

### 18. **Automated Database Maintenance**
Configured in `iaac/dev/pocketbase-maintenance.yaml`:
- **Weekly VACUUM**: Sunday 3 AM, optimizes SQLite
- **Daily Backup**: 2 AM, gzipped, 7-day retention
- Result: Consistent performance, automatic disaster recovery

### 19. **Automated Optimization Scripts**
All optimization scripts are idempotent and can be run multiple times:
- `iaac/argocd/migrate-to-core.sh`: Migrate to ArgoCD Core
- `iaac/argocd/optimize-core.sh`: Further optimize ArgoCD Core
- `iaac/optimize-k3s.sh`: Remove metrics-server, cert-manager
- `iaac/optimize-pocketbase.sh`: SQLite performance tuning
- `iaac/setup-swap.sh`: Configure emergency swap
- `iaac/monitor.sh`: Lightweight resource monitoring

## Advanced Optimizations

### 20. **Reduce ArgoCD sync interval** (save CPU cycles)
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
