# terraform-k3s-hetzner

## Objective

This spins up 1 control-plane node and 3 worker nodes in Hetzner with `k3s`.  
The Terraform code assumes you have set an `HCLOUD_TOKEN` environment variable.

## Variables

You might want to change the one variable that is in `variables.tf` to point to
your SSH key that you want to use.

## Usage

```shell
terraform init
terraform plan
terraform apply
```

After completion, run the following command to create the context for your `kubectl`.  
The IP address of the control plane node is outputted.

```shell
export CONTROL_PLANE_NODE_IP="<control-plane-node_ip>"
scp $CONTROL_PLANE_NODE_IP:/etc/rancher/k3s/k3s.yaml ~/.kube/config
sed -i "s/127.0.0.1/$CONTROL_PLANE_NODE_IP/g" ~/.kube/config
```

Install `kubectl`, I use macOS, so I used

```shell
brew install kubectl
```

Then check if you have a complete cluster:

```shell
❯ kubectl get nodes
NAME                 STATUS   ROLES                  AGE   VERSION
control-plane-node   Ready    control-plane,master   22m   v1.29.4+k3s1
worker-node-01       Ready    <none>                 21m   v1.29.4+k3s1
worker-node-02       Ready    <none>                 21m   v1.29.4+k3s1
worker-node-03       Ready    <none>                 21m   v1.29.4+k3s1
```

## Author

- Chris van Meer <c.v.meer@atcomputing.nl>
