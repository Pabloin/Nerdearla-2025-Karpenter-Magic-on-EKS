#!/bin/bash

# Kubernetes Context Manager for Multiple Clusters
# Usage: source this file to get helpful aliases

# Environment variables
export EKS_PROD_CLUSTER="pablo-karpenter-demo"
export EKS_PROD_REGION="us-west-2"
export EKS_PROD_ACCOUNT="703671890483"

export EKS_LAB_CLUSTER="karpenter-magic-1"
export EKS_LAB_REGION="us-east-1"
export EKS_LAB_ACCOUNT="381492249303"

# Aliases for quick context switching
alias k='kubectl'
alias kc='kubectl config'
alias kcc='kubectl config current-context'
alias kgc='kubectl config get-contexts'

# Switch to production cluster (Oregon)
alias k-prod='kubectl config use-context arn:aws:eks:us-west-2:703671890483:cluster/pablo-karpenter-demo'

# Switch to lab cluster (Virginia)  
alias k-lab='kubectl config use-context arn:aws:eks:us-east-1:381492249303:cluster/karpenter-magic-1'

# Quick cluster info
alias k-info='echo "Current: $(kubectl config current-context)" && kubectl get nodes'

# Functions
karpenter-status() {
    echo "=== Current Context ==="
    kubectl config current-context
    echo ""
    echo "=== Nodes ==="
    kubectl get nodes
    echo ""
    echo "=== Karpenter Pods ==="
    kubectl get pods -n karpenter 2>/dev/null || echo "Karpenter namespace not found"
    echo ""
    echo "=== NodePools ==="
    kubectl get nodepools 2>/dev/null || echo "No NodePools found or Karpenter not installed"
}

update-kubeconfig-prod() {
    echo "Updating kubeconfig for production cluster..."
    aws eks update-kubeconfig --name $EKS_PROD_CLUSTER --region $EKS_PROD_REGION
}

update-kubeconfig-lab() {
    echo "Updating kubeconfig for lab cluster..."  
    aws eks update-kubeconfig --name $EKS_LAB_CLUSTER --region $EKS_LAB_REGION
}

echo "🧊 Kubernetes Context Manager Loaded 🧊"
echo ""
echo "Available commands:"
echo "  k-prod          - Switch to production cluster (Oregon)"
echo "  k-lab           - Switch to lab cluster (Virginia)" 
echo "  kcc             - Show current context"
echo "  kgc             - Show all contexts"
echo "  k-info          - Show current context + nodes"
echo "  karpenter-status - Complete Karpenter status"
echo ""
echo "Current context: $(kubectl config current-context 2>/dev/null || echo 'None')"
