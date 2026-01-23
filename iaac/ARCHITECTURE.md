# Deployment Architecture

## High Availability Configuration

### Web Service (Flutter Frontend)
- **Replicas**: 2 pods per environment
- **Load Balancing**: Kubernetes Service (ClusterIP) automatically load balances
- **Ingress**: Traefik (k3s) or Civo LoadBalancer (production)
- **Rolling Updates**: 
  - `maxSurge: 1` - allows 1 extra pod during updates
  - `maxUnavailable: 0` - ensures at least 2 pods always running
  - Readiness probe on `/health` ensures traffic only goes to ready pods
- **PodDisruptionBudget**: Ensures at least 1 pod always available during disruptions

### PocketBase Backend (Database)
- **Replicas**: 1 pod (SQLite limitation - single-writer only)
- **Storage**: PersistentVolumeClaim (5Gi dev, 10Gi stage, 20Gi prod)
- **High Availability**: Not possible with SQLite
  - For true HA, would need to migrate to PostgreSQL/MySQL with multi-write support
  - Current setup prioritizes simplicity and resource efficiency

### ArgoCD GitOps Controller
- **Installation**: ArgoCD Core (minimal)
  - Saves ~150MB RAM vs full installation
  - Removes: Web UI, SSO/Dex, Notifications, ApplicationSets
  - Keeps: Application Controller, Repo Server, Redis
- **Management**: kubectl only (no web UI)
  ```bash
  kubectl get applications -n argocd
  kubectl patch application <app> -n argocd --type merge -p '{"operation":{"sync":{}}}'
  ```

## Environment Specifications

### Development (dev.transharbor.org)
- **Platform**: k3s on single node (1 vCPU, 2GB RAM)
- **Web**: 2 replicas with rolling updates
- **PocketBase**: 1 replica, 5Gi storage
- **Resources**: Minimal limits to maximize utilization

### Staging (stage.transharbor.org)
- **Platform**: k3s on single node (1 vCPU, 2GB RAM)
- **Web**: 2 replicas with rolling updates
- **PocketBase**: 1 replica, 10Gi storage
- **Sync**: Manual (via kubectl or promotion workflow)

### Production (app.transharbor.org)
- **Platform**: Civo Kubernetes (managed cluster)
- **Web**: 2 replicas with rolling updates
- **PocketBase**: 1 replica, 20Gi storage
- **Load Balancer**: Civo LoadBalancer (replaces Traefik ingress)
- **Sync**: Manual with confirmation workflow

## Zero-Downtime Deployments

When ArgoCD syncs a new web image:
1. New pod is created (total: 3 pods)
2. New pod passes readiness probe
3. Service adds new pod to endpoints
4. Old pod is terminated (back to 2 pods)
5. Repeat for second pod
6. No traffic disruption during entire process

PocketBase updates require brief downtime due to single replica constraint.

## Resource Usage (Development)

Current memory allocation on 2GB node:
- k3s system: ~200MB
- ArgoCD Core: ~70MB (down from 224MB)
- cert-manager: ~50MB
- PocketBase: ~15MB
- Web (2 replicas): ~14MB
- Traefik: ~30MB
- **Total**: ~379MB (19% of 2GB)
- **Available**: ~1.6GB for application workloads

## Future Considerations

### For Production Scale:
- Migrate PocketBase to PostgreSQL for multi-replica support
- Increase Civo node size or add nodes for horizontal scaling
- Consider full ArgoCD installation with UI on production cluster
- Add Prometheus/Grafana for monitoring
- Implement backup/restore automation for databases
