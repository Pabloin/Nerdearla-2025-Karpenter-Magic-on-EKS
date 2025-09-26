export CLUSTER_NAME="eks-autoscaler-demo"
export REGION="us-east-1"

eksctl create cluster \
  --name $CLUSTER_NAME \
  --region $REGION \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 5 \
  --managed



  NODEGROUP_ROLE=$(aws eks describe-nodegroup \
  --cluster-name $CLUSTER_NAME \
  --nodegroup-name $(eksctl get nodegroup --cluster $CLUSTER_NAME -o json | jq -r '.[0].Name') \
  --query "nodegroup.nodeRole" --output text)

aws iam attach-role-policy \
  --role-name $(basename $NODEGROUP_ROLE) \
  --policy-arn arn:aws:iam::aws:policy/AutoScalingFullAccess


kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/cluster-autoscaler-1.29.0/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml


kubectl -n kube-system edit deployment.apps/cluster-autoscaler