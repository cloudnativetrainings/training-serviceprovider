#!/bin/bash

export KUBECONFIG=/Users/hubert/Desktop/mallorca/kdp/kubeconfig-a7bhp87j9q

kubectl create namespace kdp-system
kubectl create secret generic k1-training-kubeconfig \
  --namespace kdp-system \
  --from-file kubeconfig=/Users/hubert/Desktop/mallorca/kdp/k1.training.cloud-native.com-kubeconfig
kubectl create secret generic kkp-training-kubeconfig \
  --namespace kdp-system \
  --from-file kubeconfig=/Users/hubert/Desktop/mallorca/kdp/kkp.training.cloud-native.com-kubeconfig
kubectl create secret generic lf-training-kubeconfig \
  --namespace kdp-system \
  --from-file kubeconfig=/Users/hubert/Desktop/mallorca/kdp/lf.training.cloud-native.com-kubeconfig
kubectl create secret generic kfo-training-kubeconfig \
  --namespace kdp-system \
  --from-file kubeconfig=/Users/hubert/Desktop/mallorca/kdp/kfo.training.cloud-native.com-kubeconfig
kubectl create secret generic ks-training-kubeconfig \
  --namespace kdp-system \
  --from-file kubeconfig=/Users/hubert/Desktop/mallorca/kdp/ks.training.cloud-native.com-kubeconfig

## sync agents

helm repo add kcp https://kcp-dev.github.io/helm-charts
helm repo update

helm upgrade --install k1-syncagent kcp/api-syncagent \
  --values k1-syncagent.yaml \
  --namespace kdp-system
helm upgrade --install  kfo-syncagent kcp/api-syncagent \
  --values kfo-syncagent.yaml \
  --namespace kdp-system
helm upgrade --install  kkp-syncagent kcp/api-syncagent \
  --values kkp-syncagent.yaml \
  --namespace kdp-system
helm upgrade --install  ks-syncagent kcp/api-syncagent \
  --values ks-syncagent.yaml \
  --namespace kdp-system
helm upgrade --install  lf-syncagent kcp/api-syncagent \
  --values lf-syncagent.yaml \
  --namespace kdp-system   

## crossplane operator     

helm repo add \
  crossplane-stable https://charts.crossplane.io/stable

helm repo update

helm upgrade --install crossplane \
  crossplane-stable/crossplane \
  --namespace crossplane-system \
  --create-namespace

## tf provider

kubectl apply -f tf-provider.yaml


## sensitive data
kubectl -n crossplane-system create secret generic gsa \
  --from-file=.vault/gcloud-service-account.json

kubectl -n crossplane-system create secret generic tfvars \
  --from-file=.vault/terraform.tfvars

# Apply Kubernetes Security Projects

kubectl apply -f ks-manifests/ks-xrd.yaml
kubectl apply -f ks-manifests/project-published-resource.yaml
 