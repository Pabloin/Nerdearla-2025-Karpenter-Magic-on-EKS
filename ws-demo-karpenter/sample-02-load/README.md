To demo Karpenter’s “magic” (automatic node provisioning and scaling), you want to show how Karpenter launches new nodes when your cluster needs more capacity. Here’s a simple, effective demo:


1. Deploy a Workload That Needs More Nodes
Deploy a large number of pods that cannot fit on your current nodes. For example, create a deployment with a high resource request:

busybox-demo.yaml

❯ kubectl apply -f nginx-deployment.yaml
deployment.apps/demo-nginx configured
❯ 
❯ 
❯ cd ../demo-nerdearla-02-load
❯ 
❯ 
❯ kubectl apply -f busybox-demo.yaml
deployment.apps/karpenter-demo created



            kubectl delete deployment karpenter-demo
            kubectl delete deployment demo-nginx





❯ kubectl get pods -o wide
kubectl get nodes -o wide --watch
NAME                              READY   STATUS        RESTARTS   AGE     IP                NODE                                            NOMINATED NODE   READINESS GATES
demo-nginx-75dc59bc9c-4snk8       1/1     Running       0          8m53s   192.168.49.253    ip-192-168-56-14.us-west-2.compute.internal     <none>           <none>
demo-nginx-75dc59bc9c-577v9       1/1     Running       0          8m53s   192.168.96.186    ip-192-168-126-165.us-west-2.compute.internal   <none>           <none>
hello                             1/1     Terminating   0          11d     192.168.135.157   ip-192-168-156-199.us-west-2.compute.internal   <none>           <none>
hello-world-6f64d78b5c-8b7zg      1/1     Running       0          135m    192.168.40.128    ip-192-168-56-14.us-west-2.compute.internal     <none>           <none>
hello-world-6f64d78b5c-f8nzf      1/1     Running       0          135m    192.168.56.176    ip-192-168-56-14.us-west-2.compute.internal     <none>           <none>
hello-world-6f64d78b5c-w6t79      1/1     Running       0          135m    192.168.94.113    ip-192-168-78-182.us-west-2.compute.internal    <none>           <none>
hello-world-6f64d78b5c-x8vtc      1/1     Running       0          135m    192.168.51.196    ip-192-168-56-14.us-west-2.compute.internal     <none>           <none>
hello-world-6f64d78b5c-xvcjv      1/1     Running       0          135m    192.168.62.160    ip-192-168-56-14.us-west-2.compute.internal     <none>           <none>
karpenter-demo-6cc88d7768-2cj2s   1/1     Running       0          2m38s   192.168.54.163    ip-192-168-56-14.us-west-2.compute.internal     <none>           <none>
karpenter-demo-6cc88d7768-5nbwp   1/1     Running       0          2m38s   192.168.153.218   ip-192-168-140-104.us-west-2.compute.internal   <none>           <none>
karpenter-demo-6cc88d7768-7tz6w   1/1     Running       0          2m38s   192.168.151.28    ip-192-168-140-104.us-west-2.compute.internal   <none>           <none>
karpenter-demo-6cc88d7768-flvp8   1/1     Running       0          2m38s   192.168.46.234    ip-192-168-56-14.us-west-2.compute.internal     <none>           <none>
karpenter-demo-6cc88d7768-hs2rq   1/1     Running       0          2m38s   192.168.155.28    ip-192-168-140-104.us-west-2.compute.internal   <none>           <none>
karpenter-demo-6cc88d7768-k48kr   1/1     Running       0          2m38s   192.168.35.101    ip-192-168-56-14.us-west-2.compute.internal     <none>           <none>
karpenter-demo-6cc88d7768-l947p   1/1     Running       0          2m38s   192.168.153.233   ip-192-168-140-104.us-west-2.compute.internal   <none>           <none>
karpenter-demo-6cc88d7768-lkb5h   1/1     Running       0          2m38s   192.168.147.117   ip-192-168-140-104.us-west-2.compute.internal   <none>           <none>
karpenter-demo-6cc88d7768-tlwvd   1/1     Running       0          2m38s   192.168.140.249   ip-192-168-140-104.us-west-2.compute.internal   <none>           <none>
karpenter-demo-6cc88d7768-x9sbk   1/1     Running       0          2m38s   192.168.138.190   ip-192-168-140-104.us-west-2.compute.internal   <none>           <none>
NAME                                            STATUS     ROLES    AGE     VERSION               INTERNAL-IP       EXTERNAL-IP      OS-IMAGE         KERNEL-VERSION                  CONTAINER-RUNTIME
ip-192-168-126-165.us-west-2.compute.internal   Ready      <none>   4d8h    v1.32.8-eks-99d6cc0   192.168.126.165   <none>           Amazon Linux 2   5.10.240-238.959.amzn2.x86_64   containerd://1.7.27
ip-192-168-140-104.us-west-2.compute.internal   Ready      <none>   2m37s   v1.32.9-eks-113cf36   192.168.140.104   <none>           Amazon Linux 2   5.10.242-239.961.amzn2.x86_64   containerd://1.7.27
ip-192-168-156-199.us-west-2.compute.internal   NotReady   <none>   14d     v1.32.8-eks-99d6cc0   192.168.156.199   <none>           Amazon Linux 2   5.10.240-238.959.amzn2.x86_64   containerd://1.7.27
ip-192-168-56-14.us-west-2.compute.internal     Ready      <none>   135m    v1.32.9-eks-113cf36   192.168.56.14     44.233.249.175   Amazon Linux 2   5.10.242-239.961.amzn2.x86_64   containerd://1.7.27
ip-192-168-56-3.us-west-2.compute.internal      Ready      <none>   4d8h    v1.32.8-eks-99d6cc0   192.168.56.3      44.250.201.65    Amazon Linux 2   5.10.240-238.959.amzn2.x86_64   containerd://1.7.27
ip-192-168-78-182.us-west-2.compute.internal    Ready      <none>   4d8h    v1.32.8-eks-99d6cc0   192.168.78.182    54.185.117.26    Amazon Linux 2   5.10.240-238.959.amzn2.x86_64   containerd://1.7.27



What Does This Mean?
You deployed a workload (karpenter-demo) that requested more resources than your cluster had available.
Karpenter detected the pending pods and automatically provisioned new EC2 nodes to fit them.
You can see new nodes (with recent AGE, e.g. 2m37s) in your kubectl get nodes output.
The pods are now running and distributed across both old and new nodes.
How to Demo This
Show your deployment:
kubectl apply -f busybox-demo.yaml
Show pods pending, then running:
kubectl get pods -o wide
Show new nodes appear:
kubectl get nodes -o wide --watch
Explain:
“Karpenter automatically detects when pods can’t be scheduled, and provisions new nodes with the right capacity. When I delete the deployment, Karpenter will terminate the now-unused nodes.”
How to Show Scale Down
Delete the demo deployment:

Watch as Karpenter deprovisions the extra nodes after a few minutes.

Summary
Karpenter = automatic, fast, right-sized node provisioning.
Demo = deploy big workload → watch new nodes appear → delete workload → watch nodes disappear.
You’re ready to show off Karpenter’s “magic” live! 🚀




❯ kubectl get pods -o wide
kubectl get nodes -o wide --watch
❯ kubectl get pods -o wide
NAME                           READY   STATUS        RESTARTS   AGE    IP                NODE                                            NOMINATED NODE   READINESS GATES
demo-nginx-75dc59bc9c-4snk8    1/1     Running       0          29m    192.168.49.253    ip-192-168-56-14.us-west-2.compute.internal     <none>           <none>
demo-nginx-75dc59bc9c-577v9    1/1     Running       0          29m    192.168.96.186    ip-192-168-126-165.us-west-2.compute.internal   <none>           <none>
hello                          1/1     Terminating   0          11d    192.168.135.157   ip-192-168-156-199.us-west-2.compute.internal   <none>           <none>
hello-world-6f64d78b5c-8b7zg   1/1     Running       0          155m   192.168.40.128    ip-192-168-56-14.us-west-2.compute.internal     <none>           <none>
hello-world-6f64d78b5c-f8nzf   1/1     Running       0          155m   192.168.56.176    ip-192-168-56-14.us-west-2.compute.internal     <none>           <none>
hello-world-6f64d78b5c-w6t79   1/1     Running       0          155m   192.168.94.113    ip-192-168-78-182.us-west-2.compute.internal    <none>           <none>
hello-world-6f64d78b5c-x8vtc   1/1     Running       0          155m   192.168.51.196    ip-192-168-56-14.us-west-2.compute.internal     <none>           <none>
hello-world-6f64d78b5c-xvcjv   1/1     Running       0          155m   192.168.62.160    ip-192-168-56-14.us-west-2.compute.internal     <none>           <none>
❯ kubectl get nodes -o wide
NAME                                            STATUS     ROLES    AGE    VERSION               INTERNAL-IP       EXTERNAL-IP      OS-IMAGE         KERNEL-VERSION                  CONTAINER-RUNTIME
ip-192-168-126-165.us-west-2.compute.internal   Ready      <none>   4d8h   v1.32.8-eks-99d6cc0   192.168.126.165   <none>           Amazon Linux 2   5.10.240-238.959.amzn2.x86_64   containerd://1.7.27
ip-192-168-156-199.us-west-2.compute.internal   NotReady   <none>   14d    v1.32.8-eks-99d6cc0   192.168.156.199   <none>           Amazon Linux 2   5.10.240-238.959.amzn2.x86_64   containerd://1.7.27
ip-192-168-56-14.us-west-2.compute.internal     Ready      <none>   155m   v1.32.9-eks-113cf36   192.168.56.14     44.233.249.175   Amazon Linux 2   5.10.242-239.961.amzn2.x86_64   containerd://1.7.27
ip-192-168-56-3.us-west-2.compute.internal      Ready      <none>   4d8h   v1.32.8-eks-99d6cc0   192.168.56.3      44.250.201.65    Amazon Linux 2   5.10.240-238.959.amzn2.x86_64   containerd://1.7.27
ip-192-168-78-182.us-west-2.compute.internal    Ready      <none>   4d8h   v1.32.8-eks-99d6cc0   192.168.78.182    54.185.117.26    Amazon Linux 2   5.10.240-238.959.amzn2.x86_64   containerd://1.7.27