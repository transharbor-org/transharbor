#!/bin/bash
# Configure swap on k3s node for OOM protection
# Only use when memory is critically low
# Run on the k3s node, not in a pod

set -e

SWAP_SIZE="${1:-1G}"  # Default 1GB swap

echo "Configuring ${SWAP_SIZE} swap for OOM protection..."

# Check if swap already exists
if [ $(swapon --show | wc -l) -gt 0 ]; then
    echo "Swap already configured:"
    swapon --show
    echo
    read -p "Do you want to reconfigure? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
    swapoff -a
fi

# Create swap file
echo "Creating ${SWAP_SIZE} swap file..."
fallocate -l ${SWAP_SIZE} /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=1024
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# Make persistent
if ! grep -q '/swapfile' /etc/fstab; then
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

# Tune swappiness for k8s (only swap when absolutely necessary)
sysctl vm.swappiness=10
echo 'vm.swappiness=10' >> /etc/sysctl.conf

# Tune cache pressure (keep directory/inode objects in memory)
sysctl vm.vfs_cache_pressure=50
echo 'vm.vfs_cache_pressure=50' >> /etc/sysctl.conf

echo
echo "Swap configuration complete!"
swapon --show
echo
echo "Swappiness: $(cat /proc/sys/vm/swappiness)"
echo "Cache pressure: $(cat /proc/sys/vm/vfs_cache_pressure)"
echo
echo "This provides ~1GB emergency memory when RAM is exhausted."
echo "Kubelet will still prefer to evict low-priority pods first."
