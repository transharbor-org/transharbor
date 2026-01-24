#!/bin/bash
# Set ArgoCD reconciliation interval to 1 minute

echo "Setting ArgoCD reconciliation interval to 60 seconds..."

kubectl patch configmap argocd-cm -n argocd --type merge -p='{
  "data": {
    "timeout.reconciliation": "60s"
  }
}'

echo "Restarting ArgoCD application controller..."
kubectl rollout restart deployment argocd-application-controller -n argocd

echo "Done! ArgoCD will now check for changes every minute."
