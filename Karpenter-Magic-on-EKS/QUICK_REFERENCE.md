# 🧊 Karpenter Quick Reference

## 🚀 Quick Commands

```bash
# Environment setup
export EKS_CLUSTER_NAME=pablo-karpenter-demo
export AWS_REGION=us-west-2
export AWS_ACCOUNT_ID=703671890483

# Status checks
./check-status.sh                     # Full status check
kubectl get nodes                     # List all nodes
kubectl get pods -n karpenter         # Karpenter pods
kubectl get nodepools                 # NodePools configuration
kubectl get nodeclaims                # Active node claims

# Test Karpenter magic
kubectl apply -f test-workload.yaml   # Deploy test workload
kubectl delete -f test-workload.yaml  # Remove test workload

# Context switching (if using multiple clusters)
source kube-context-manager.sh        # Load context manager
k-prod                                # Switch to production cluster
k-lab                                 # Switch to lab cluster
```

## 📁 Files Overview

| File | Purpose |
|------|---------|
| `README_INSTALL.md` | Complete installation guide |
| `check-status.sh` | Status checker script |
| `kube-context-manager.sh` | Multi-cluster context manager |
| `test-workload.yaml` | Test deployment for scaling |
| `config/karpenter-config.yaml` | NodePool configuration |
| `config/*-policy.json` | IAM policies |

## 🧊 Cluster Info

- **Cluster:** pablo-karpenter-demo
- **Region:** us-west-2 (Oregon)
- **Account:** TBD
- **Karpenter Version:** 0.16.3
- **Bootstrap Node:** karpenter-bootstrap node group

## ⚡ Magic Commands

```bash
# Watch nodes scale in real-time
kubectl get nodes -w

# Follow Karpenter logs
kubectl logs -n karpenter deployment/karpenter -f

# Check what Karpenter is doing
kubectl describe nodeclaims

# See node costs and efficiency
kubectl get nodeclaims -o wide
```

---
🧊✨ **Ready for Karpenter Magic!** ✨🧊
