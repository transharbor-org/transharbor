# Image Pull Optimization Guide

## Problem
Image pulls can be slow and consume bandwidth, especially for Flutter web builds with many assets.

## Solutions Implemented

### 1. Layer Caching in Dockerfiles
**Web Dockerfile:**
- nginx:alpine base layer is cached (rarely changes)
- nginx.conf copied separately (changes infrequently)
- Flutter build copied last (changes most often)

**PocketBase Dockerfile:**
- alpine:3.18 builder cached
- PocketBase binary version pinned (0.18.10)
- distroless runtime layer cached

### 2. GitHub Actions Cache
Add to `.github/workflows/flutter-ci.yml`:
```yaml
build-and-push-images:
  steps:
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3
      with:
        buildkitd-flags: --debug
    
    - name: Cache Docker layers
      uses: actions/cache@v3
      with:
        path: /tmp/.buildx-cache
        key: ${{ runner.os }}-buildx-${{ github.sha }}
        restore-keys: |
          ${{ runner.os }}-buildx-
    
    - name: Build Web
      uses: docker/build-push-action@v5
      with:
        context: .
        file: ./Dockerfile
        push: true
        tags: |
          ghcr.io/${{ github.repository }}/web:main
          ghcr.io/${{ github.repository }}/web:main-${{ github.sha }}
        cache-from: type=local,src=/tmp/.buildx-cache
        cache-to: type=local,dest=/tmp/.buildx-cache-new,mode=max
    
    - name: Move cache
      run: |
        rm -rf /tmp/.buildx-cache
        mv /tmp/.buildx-cache-new /tmp/.buildx-cache
```

### 3. k3s Image Preloading
On the k3s node, preload common images:
```bash
# Preload images to avoid pull delays during deployments
ssh root@dev.transharbor.org << 'EOF'
docker pull nginx:alpine
docker pull gcr.io/distroless/static-debian12:nonroot
docker pull alpine:3.18

# Import into containerd
ctr -n k8s.io image import /var/lib/rancher/k3s/agent/images/*
EOF
```

### 4. Registry Mirror (Advanced)
For production with frequent deployments, consider a registry mirror:
```bash
# Add to /etc/rancher/k3s/registries.yaml on k3s node
mirrors:
  ghcr.io:
    endpoint:
      - "https://ghcr.io"
    rewrite:
      "^(.*)$": "$1"
```

## Expected Impact
- **Build time:** 3-5 minutes → 1-2 minutes (with cache)
- **Pull time:** 30-60s → 5-10s (with cached layers)
- **Bandwidth:** ~100MB → ~10MB (delta only)

## Monitoring
Check image pull times:
```bash
kubectl describe pod <pod-name> -n transharbor | grep -A5 "Events:"
# Look for "Pulling image" and "Successfully pulled image" timestamps
```

## Notes
- Docker layer cache is most effective when layers don't change
- GitHub Actions cache has 10GB limit per repository
- k3s/containerd automatically caches pulled images
- Use `crictl rmi` to force fresh pull when needed
