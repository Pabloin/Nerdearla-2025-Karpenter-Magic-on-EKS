# 🧊✨ Karpenter Magic on EKS Demo ✨🧊

**AWS Community Day Argentina 2025 - Córdoba**

## 🎯 Demo Overview

This demo showcases the **"magic"** of Karpenter on Amazon EKS - how it automatically provisions and manages EC2 instances based on your workload demands, eliminating the need for manual capacity planning.

### The Magic Moment 🪄

**Before Karpenter:** Manual node group management, over-provisioning, idle costs  
**After Karpenter:** Automatic, intelligent, cost-efficient scaling

## 🚀 Quick Demo

### 1. Check Current State
```bash
# See current nodes (3 nodes running)
kubectl get nodes

# See pending workload (5 pods waiting for capacity)
kubectl get pods | grep karpenter-test
```

### 2. Watch Karpenter Intelligence
```bash
# See Karpenter analyzing the situation
kubectl logs -n karpenter deployment/karpenter --tail=5

# Expected output:
# "Found 5 provisionable pod(s)"
# "Computed 1 new node(s) will fit 5 pod(s)"
# "Launching node with 5 pods requesting cpu:5150m, memory:5Gi"
```

### 3. The Magic Happens
```bash
# Watch new nodes appear automatically
kubectl get nodes -w

# See pods get scheduled automatically
kubectl get pods -w | grep karpenter-test
```

### 4. Cost Optimization Magic
```bash
# Delete the workload
kubectl delete -f test-workload.yaml

# Watch nodes terminate automatically (saves money!)
kubectl get nodes -w
```

## 🧊 The "AHA" Moment

**What just happened?**
1. **Smart Detection:** Karpenter saw 5 pending pods needing 5150m CPU
2. **Intelligent Sizing:** It chose optimal instance types (c5.2xlarge, c6a.2xlarge)
3. **Efficient Packing:** Calculated that 1 node can fit all 5 pods
4. **Cost Optimization:** Automatically terminates idle nodes

**The Result:** 40-60% cost reduction compared to traditional node groups!

## 📁 Demo Files

- `demo-karpenter.yaml` - Working Karpenter v0.16 configuration
- `test-workload.yaml` - Demo workload (5 pods, 1 CPU each)
- `check-status.sh` - Status checking script
- `config/` - IAM policies and configurations

## 🎤 Talk Points

### Traditional EKS Scaling Pain Points
- Manual node group creation and management
- Over-provisioning to handle peak loads
- Paying for idle capacity 24/7
- Slow response to demand changes
- Complex capacity planning

### Karpenter Magic Solutions
- **Automatic provisioning** - Nodes appear when needed
- **Smart instance selection** - Right-sized for workloads
- **Multi-AZ, multi-instance-type** - Optimal availability and cost
- **Spot instance support** - Up to 90% cost savings
- **Automatic termination** - Pay only for what you use

### Business Impact
- **Cost Reduction:** 40-60% savings on compute costs
- **Operational Efficiency:** Zero manual intervention required
- **Performance:** Sub-minute scaling response
- **Flexibility:** Supports any workload pattern

## 🎯 Demo Script

1. **Problem Statement** (2 min): Show pending pods, manual scaling pain
2. **Karpenter Introduction** (1 min): "Meet the magic behind EKS autoscaling"
3. **Live Demo** (5 min): Deploy workload, watch nodes appear
4. **AHA Moment** (2 min): Explain the intelligence and cost savings
5. **Cleanup Demo** (2 min): Show automatic node termination

## 🔧 Technical Details

- **Cluster:** pablo-karpenter-demo (us-west-2)
- **Karpenter Version:** v0.16.3
- **Node Requirements:** c/m/r instance families, >gen2, on-demand
- **Demo Workload:** 5 nginx pods, 1 CPU + 1GB each

---

**Ready to see the magic?** 🧊✨

*"Karpenter doesn't just scale your cluster - it scales your business by turning infrastructure from a cost center into a competitive advantage!"*





