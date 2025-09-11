#!/bin/bash

echo "🧊✨ KARPENTER MAGIC STATUS CHECKER ✨🧊"
echo "=========================================="
echo ""

# Set environment variables
export EKS_CLUSTER_NAME=pablo-karpenter-demo
export AWS_REGION=us-west-2
export AWS_ACCOUNT_ID=TBD

echo "📋 CLUSTER INFO:"
echo "  Cluster: $EKS_CLUSTER_NAME"
echo "  Region: $AWS_REGION"
echo "  Account: $AWS_ACCOUNT_ID"
echo ""

echo "🔍 CURRENT STATUS:"
echo ""

# Check cluster status
echo "1️⃣ EKS Cluster Status:"
CLUSTER_STATUS=$(aws eks describe-cluster --name $EKS_CLUSTER_NAME --region $AWS_REGION --query "cluster.status" --output text 2>/dev/null || echo "ERROR")
echo "   Status: $CLUSTER_STATUS"
echo ""

# Check node group status  
echo "2️⃣ Bootstrap Node Group Status:"
NODEGROUP_STATUS=$(aws eks describe-nodegroup --cluster-name $EKS_CLUSTER_NAME --nodegroup-name "karpenter-bootstrap" --region $AWS_REGION --query "nodegroup.status" --output text 2>/dev/null || echo "NOT_FOUND")
echo "   Status: $NODEGROUP_STATUS"
echo ""

# Check nodes
echo "3️⃣ Worker Nodes:"
NODE_COUNT=$(kubectl get nodes --no-headers 2>/dev/null | wc -l)
if [ "$NODE_COUNT" -gt 0 ]; then
    echo "   ✅ $NODE_COUNT nodes found:"
    kubectl get nodes
else
    echo "   ⏳ No nodes yet (still creating...)"
fi
echo ""

# Check Karpenter installation
echo "4️⃣ Karpenter Installation:"
KARPENTER_RELEASE=$(helm list -n karpenter -q 2>/dev/null)
if [ -n "$KARPENTER_RELEASE" ]; then
    echo "   ✅ Helm release: $KARPENTER_RELEASE"
    KARPENTER_PODS=$(kubectl get pods -n karpenter --no-headers 2>/dev/null | wc -l)
    echo "   📦 Pods: $KARPENTER_PODS"
    if [ "$KARPENTER_PODS" -gt 0 ]; then
        kubectl get pods -n karpenter
    fi
else
    echo "   ❌ Karpenter not installed yet"
fi
echo ""

# Check NodePools
echo "5️⃣ NodePools Configuration:"
NODEPOOL_COUNT=$(kubectl get nodepools --no-headers 2>/dev/null | wc -l)
if [ "$NODEPOOL_COUNT" -gt 0 ]; then
    echo "   ✅ $NODEPOOL_COUNT NodePools found:"
    kubectl get nodepools
else
    echo "   ⏳ No NodePools configured yet"
fi
echo ""

echo "🚀 NEXT STEPS:"
if [ "$NODE_COUNT" -eq 0 ]; then
    echo "   ⏳ Waiting for bootstrap node group to complete..."
elif [ -z "$KARPENTER_RELEASE" ]; then
    echo "   🎯 Ready to install Karpenter!"
elif [ "$KARPENTER_PODS" -eq 0 ]; then
    echo "   🔧 Karpenter installed, waiting for pods to start..."
elif [ "$NODEPOOL_COUNT" -eq 0 ]; then
    echo "   📝 Ready to configure NodePools!"
else
    echo "   ✨ Ready for KARPENTER MAGIC testing! ✨"
fi
echo ""
echo "🧊 Use: ./check-status.sh to run this check again"
