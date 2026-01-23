#!/bin/bash
# Simple resource monitoring without Prometheus overhead
# Uses kubectl top and saves to /tmp/metrics.log

NAMESPACE="${1:-transharbor}"
INTERVAL="${2:-60}"  # seconds

echo "Starting lightweight monitoring for namespace: ${NAMESPACE}"
echo "Collecting metrics every ${INTERVAL} seconds"
echo "Logs saved to /tmp/metrics-${NAMESPACE}.log"
echo "Press Ctrl+C to stop"
echo

LOG_FILE="/tmp/metrics-${NAMESPACE}.log"

# Initialize log
echo "# Transharbor Resource Monitoring" > "$LOG_FILE"
echo "# Started: $(date)" >> "$LOG_FILE"
echo >> "$LOG_FILE"

while true; do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "=== ${TIMESTAMP} ===" | tee -a "$LOG_FILE"
    
    # Node resources
    echo "Node:" | tee -a "$LOG_FILE"
    kubectl top nodes | tee -a "$LOG_FILE"
    echo | tee -a "$LOG_FILE"
    
    # Pod resources
    echo "Pods in ${NAMESPACE}:" | tee -a "$LOG_FILE"
    kubectl top pods -n "$NAMESPACE" 2>/dev/null | tee -a "$LOG_FILE" || echo "metrics-server not available" | tee -a "$LOG_FILE"
    echo | tee -a "$LOG_FILE"
    
    # ArgoCD resources (if exists)
    echo "ArgoCD:" | tee -a "$LOG_FILE"
    kubectl top pods -n argocd 2>/dev/null | tee -a "$LOG_FILE" || echo "ArgoCD not monitored" | tee -a "$LOG_FILE"
    echo | tee -a "$LOG_FILE"
    
    # Pod status
    echo "Pod Status:" | tee -a "$LOG_FILE"
    kubectl get pods -n "$NAMESPACE" -o wide | tee -a "$LOG_FILE"
    echo | tee -a "$LOG_FILE"
    
    # Storage usage
    echo "PVC Usage:" | tee -a "$LOG_FILE"
    kubectl get pvc -n "$NAMESPACE" | tee -a "$LOG_FILE"
    echo | tee -a "$LOG_FILE"
    
    echo "----------------------------------------" | tee -a "$LOG_FILE"
    echo | tee -a "$LOG_FILE"
    
    sleep "$INTERVAL"
done
