#!/bin/bash
# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

mkdir calico

cd calico

curl https://docs.projectcalico.org/v${calico_version}/manifests/calico-policy-only.yaml -O

sed -i -e "s?192.168.0.0/16?${pod_cidr}?g" calico-policy-only.yaml

sleep 10

if [ ${number_of_nodes} -gt 50 ]; then
  echo "More than 50 nodes detected. Setting the typha service name"
  sed -i -e 's/typha_service_name:\s"none"/typha_service_name: calico-typha/g' calico-policy-only.yaml
  kubectl apply -f calico-policy-only.yaml
  kubectl -n kube-system scale --current-replicas=1 --replicas=${number_of_replicas} deployment/calico-typha
else
  kubectl apply -f calico-policy-only.yaml
fi
