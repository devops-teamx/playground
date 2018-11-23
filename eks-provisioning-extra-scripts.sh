#!/bin/bash

ENV=$1

export AWS_PROFILE=terraform


terraform output kubeconfig > ~/.kube/config-${ENV}

export KUBECONFIG=$KUBECONFIG:~/.kube/config-${ENV}

terraform output config_map_aws_auth > yaml/config_map_aws_auth.yaml

kubectl apply -f yaml/config_map_aws_auth.yaml

kubectl apply -f yaml/storage-class.yaml

kubectl apply -f \
https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml

kubectl apply -f \
https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/heapster.yaml

kubectl apply -f \
https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/influxdb.yaml

kubectl apply -f \
https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/rbac/heapster-rbac.yaml

kubectl apply -f yaml/eks-admin-service-account.yaml

kubectl apply -f yaml/eks-admin-cluster-role-binding.yaml

kubectl -n kube-system describe secret \
$(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}') >> token_file_created_run_time.txt

kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
