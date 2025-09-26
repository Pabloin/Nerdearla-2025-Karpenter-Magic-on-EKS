
kubectl get pods -n kube-system | grep cluster-autoscaler


kubectl logs deployment/cluster-autoscaler -n kube-system --tail=10



# -----[ AUTOSCALER ]----------------------------

## Watch pods getting created
kubectl get pods -l app=nginx-scale-test -w

## In another terminal, watch nodes being added
kubectl get nodes -w

## Scale down the deployment
kubectl scale deployment nginx-scale-test --replicas=1

## Show immediate pod termination
kubectl get pods -l app=nginx-scale-test

# -----[ TIMING MEASUREMENTS ]----------------------------

## Scale to 1 replica (timing baseline)
date && kubectl scale deployment nginx-scale-test --replicas=1 && kubectl get nodes

## Scale to 20 replicas (measure scale-up time)
date && kubectl scale deployment nginx-scale-test --replicas=20 && watch "kubectl get nodes; echo; kubectl get pods -l app=nginx-scale-test"

## Back to 1 replica (measure scale-down)
date && kubectl scale deployment nginx-scale-test --replicas=1 && watch "kubectl get nodes; echo; kubectl get pods -l app=nginx-scale-test"

## Record timestamps
echo "Cluster Autoscaler Timing:" > autoscaler-times.txt
date >> autoscaler-times.txt



# -----[ AUTOSCALER ]-----------------------------------------------

# 1. Show starting point
echo "=== Starting with 2 nodes ==="
kubectl get nodes

# 2. Deploy high-resource workload
echo "=== Deploying 10 nginx pods (500m CPU each) ==="
kubectl apply -f test-autoscaling.yaml

# 3. Show pods pending
kubectl get pods -l app=nginx-scale-test

# 4. Wait and show new nodes (or show pre-scaled result)
echo "=== Cluster Autoscaler added new nodes! ==="
kubectl get nodes

# 5. Show all pods running
kubectl get pods -l app=nginx-scale-test -o wide

# 6. Access the service
kubectl get svc nginx-scale-test