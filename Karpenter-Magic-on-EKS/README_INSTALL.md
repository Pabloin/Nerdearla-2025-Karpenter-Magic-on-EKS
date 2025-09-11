# 🧊✨ Karpenter Installation Guide ✨🧊

Complete guide for installing Karpenter on EKS cluster `pablo-karpenter-demo`

## 📋 Prerequisites

- EKS cluster: `pablo-karpenter-demo`
- Region: `us-west-2` (Oregon)
- Account: `TBD`
- AWS CLI configured with administrator access
- kubectl configured
- Helm 3.x installed

## 🚀 Installation Steps

### Step 1: Environment Setup

```bash
# Set environment variables
export EKS_CLUSTER_NAME=pablo-karpenter-demo
export AWS_REGION=us-west-2
export AWS_ACCOUNT_ID=TBD

# Update kubeconfig
aws eks update-kubeconfig --name $EKS_CLUSTER_NAME --region $AWS_REGION
```

### Step 2: Create OIDC Identity Provider

```bash
# Get OIDC issuer URL
OIDC_ISSUER=$(aws eks describe-cluster --name $EKS_CLUSTER_NAME --region $AWS_REGION --query "cluster.identity.oidc.issuer" --output text)
OIDC_ID=$(echo $OIDC_ISSUER | cut -d '/' -f 5)

# Create OIDC identity provider (if not exists)
aws iam create-open-id-connect-provider \
    --url $OIDC_ISSUER \
    --client-id-list sts.amazonaws.com \
    --thumbprint-list 9e99a48a9960b14926bb7f3b02e22da2b0ab7280
```

### Step 3: Create IAM Roles

#### 3.1 Karpenter Controller Role

```bash
# Create trust policy for Karpenter controller
cat > config/karpenter-trust-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::$AWS_ACCOUNT_ID:oidc-provider/oidc.eks.$AWS_REGION.amazonaws.com/id/$OIDC_ID"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "oidc.eks.$AWS_REGION.amazonaws.com/id/$OIDC_ID:aud": "sts.amazonaws.com",
                    "oidc.eks.$AWS_REGION.amazonaws.com/id/$OIDC_ID:sub": "system:serviceaccount:karpenter:karpenter"
                }
            }
        }
    ]
}
EOF

# Create controller policy
cat > config/karpenter-controller-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter",
                "ec2:DescribeImages",
                "ec2:RunInstances",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeLaunchTemplates",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeInstanceTypeOfferings",
                "ec2:DescribeAvailabilityZones",
                "ec2:DeleteLaunchTemplate",
                "ec2:CreateTags",
                "ec2:CreateLaunchTemplate",
                "ec2:CreateFleet",
                "ec2:TerminateInstances",
                "pricing:GetProducts",
                "iam:PassRole"
            ],
            "Resource": "*"
        }
    ]
}
EOF

# Create IAM policy and role
aws iam create-policy \
    --policy-name KarpenterControllerPolicy-$EKS_CLUSTER_NAME \
    --policy-document file://config/karpenter-controller-policy.json

aws iam create-role \
    --role-name KarpenterControllerRole-$EKS_CLUSTER_NAME \
    --assume-role-policy-document file://config/karpenter-trust-policy.json

aws iam attach-role-policy \
    --role-name KarpenterControllerRole-$EKS_CLUSTER_NAME \
    --policy-arn arn:aws:iam::$AWS_ACCOUNT_ID:policy/KarpenterControllerPolicy-$EKS_CLUSTER_NAME
```

#### 3.2 Node Instance Role

```bash
# Create trust policy for EC2 instances
cat > config/node-trust-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF

# Create node instance role
aws iam create-role \
    --role-name KarpenterNodeInstanceRole \
    --assume-role-policy-document file://config/node-trust-policy.json

# Attach required AWS managed policies
aws iam attach-role-policy \
    --role-name KarpenterNodeInstanceRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy

aws iam attach-role-policy \
    --role-name KarpenterNodeInstanceRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy

aws iam attach-role-policy \
    --role-name KarpenterNodeInstanceRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
```

### Step 4: Tag Resources for Karpenter Discovery

```bash
# Get VPC resources
VPC_ID=$(aws eks describe-cluster --name $EKS_CLUSTER_NAME --region $AWS_REGION --query "cluster.resourcesVpcConfig.vpcId" --output text)
SUBNET_IDS=$(aws eks describe-cluster --name $EKS_CLUSTER_NAME --region $AWS_REGION --query "cluster.resourcesVpcConfig.subnetIds" --output text)
SECURITY_GROUP_IDS=$(aws eks describe-cluster --name $EKS_CLUSTER_NAME --region $AWS_REGION --query "cluster.resourcesVpcConfig.securityGroupIds" --output text)

# Tag subnets
for subnet in $SUBNET_IDS; do
    aws ec2 create-tags \
        --region $AWS_REGION \
        --resources $subnet \
        --tags Key=karpenter.sh/discovery,Value=$EKS_CLUSTER_NAME
done

# Tag security groups
for sg in $SECURITY_GROUP_IDS; do
    aws ec2 create-tags \
        --region $AWS_REGION \
        --resources $sg \
        --tags Key=karpenter.sh/discovery,Value=$EKS_CLUSTER_NAME
done
```

### Step 5: Create Bootstrap Node Group

**⚠️ Critical Step:** Karpenter needs at least one node to run on!

```bash
# Create temporary managed node group for bootstrapping
aws eks create-nodegroup \
    --cluster-name $EKS_CLUSTER_NAME \
    --nodegroup-name "karpenter-bootstrap" \
    --instance-types "t3.medium" \
    --ami-type "AL2_x86_64" \
    --node-role "arn:aws:iam::$AWS_ACCOUNT_ID:role/KarpenterNodeInstanceRole" \
    --subnets $SUBNET_IDS \
    --capacity-type "ON_DEMAND" \
    --scaling-config minSize=1,maxSize=2,desiredSize=1 \
    --region $AWS_REGION

# Wait for node group to be ACTIVE (3-5 minutes)
aws eks wait nodegroup-active \
    --cluster-name $EKS_CLUSTER_NAME \
    --nodegroup-name "karpenter-bootstrap" \
    --region $AWS_REGION
```

### Step 6: Install Karpenter with Helm

```bash
# Add Karpenter Helm repository
helm repo add karpenter https://charts.karpenter.sh/
helm repo update

# Get cluster endpoint
CLUSTER_ENDPOINT=$(aws eks describe-cluster --name $EKS_CLUSTER_NAME --region $AWS_REGION --query "cluster.endpoint" --output text)

# Install Karpenter
helm install karpenter karpenter/karpenter \
    --version "0.16.3" \
    --namespace "karpenter" \
    --create-namespace \
    --set "serviceAccount.annotations.eks\.amazonaws\.com/role-arn=arn:aws:iam::$AWS_ACCOUNT_ID:role/KarpenterControllerRole-$EKS_CLUSTER_NAME" \
    --set "controller.clusterName=$EKS_CLUSTER_NAME" \
    --set "controller.clusterEndpoint=$CLUSTER_ENDPOINT"
```

### Step 7: Verify Installation

```bash
# Check Karpenter pods
kubectl get pods -n karpenter

# Check existing NodePools
kubectl get nodepools

# Run comprehensive status check
./check-status.sh
```

## 🧊 Configuration Files Created

- `config/karpenter-trust-policy.json` - IAM trust policy for controller
- `config/karpenter-controller-policy.json` - IAM permissions for controller  
- `config/node-trust-policy.json` - IAM trust policy for nodes
- `config/karpenter-config.yaml` - NodePool and EC2NodeClass configuration
- `test-workload.yaml` - Test deployment to trigger scaling
- `check-status.sh` - Status checker script
- `kube-context-manager.sh` - Multi-cluster context manager

## 🎯 Testing Karpenter Magic

Deploy test workload to see automatic node scaling:

```bash
# Deploy test workload (5 pods requesting 1 CPU each)
kubectl apply -f test-workload.yaml

# Watch Karpenter create new nodes
kubectl get nodes -w

# Check Karpenter logs
kubectl logs -n karpenter deployment/karpenter -f

# Clean up test workload
kubectl delete -f test-workload.yaml

# Watch nodes scale down automatically
kubectl get nodes -w
```

## 🧹 Cleanup (Optional)

To remove everything:

```bash
# Delete test workload
kubectl delete -f test-workload.yaml

# Uninstall Karpenter
helm uninstall karpenter -n karpenter
kubectl delete namespace karpenter

# Delete node group
aws eks delete-nodegroup \
    --cluster-name $EKS_CLUSTER_NAME \
    --nodegroup-name "karpenter-bootstrap" \
    --region $AWS_REGION

# Delete IAM resources
aws iam detach-role-policy --role-name KarpenterControllerRole-$EKS_CLUSTER_NAME --policy-arn arn:aws:iam::$AWS_ACCOUNT_ID:policy/KarpenterControllerPolicy-$EKS_CLUSTER_NAME
aws iam delete-role --role-name KarpenterControllerRole-$EKS_CLUSTER_NAME
aws iam delete-policy --policy-arn arn:aws:iam::$AWS_ACCOUNT_ID:policy/KarpenterControllerPolicy-$EKS_CLUSTER_NAME
aws iam delete-role --role-name KarpenterNodeInstanceRole
```

## 📚 Key Resources

- **Cluster:** pablo-karpenter-demo (us-west-2)
- **Controller Role:** KarpenterControllerRole-pablo-karpenter-demo  
- **Node Role:** KarpenterNodeInstanceRole
- **NodePool:** default (configured for c/m/r instances, spot+on-demand)
- **Bootstrap Node Group:** karpenter-bootstrap (can be deleted after setup)

## 🚀 What's Next?

1. **Test scaling:** Deploy workloads and watch automatic node provisioning
2. **Configure NodePools:** Customize instance types, spot vs on-demand
3. **Set up monitoring:** CloudWatch metrics for Karpenter operations
4. **Production tuning:** Adjust consolidation policies and limits

---

🧊✨ **KARPENTER MAGIC IS NOW READY!** ✨🧊

Nodes will automatically appear when needed and disappear when not! 🎭
