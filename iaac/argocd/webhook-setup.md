# ArgoCD Webhook Setup for GitHub
# Saves CPU by using push-based updates instead of 3-minute polling

## Setup on dev server:

1. Get ArgoCD webhook URL (for Core installation):
```bash
# ArgoCD Core doesn't expose webhooks by default
# Keep using polling (3min) - minimal CPU impact on small cluster
```

## Alternative: Use GitHub Actions to trigger sync

Add to .github/workflows/flutter-ci.yml after updating manifests:

```yaml
- name: Trigger ArgoCD sync
  if: github.ref == 'refs/heads/main'
  run: |
    kubectl patch application transharbor-dev -n argocd \
      --type merge \
      -p '{"operation":{"sync":{"prune":true,"dryRun":false}}}'
```

Requires KUBECONFIG secret in GitHub Actions.

## For production (Civo K8s):
Use full ArgoCD with webhook support via ingress.
