#!/bin/bash

export ACCOUNT_NO=$1
export ECR_REPO=$2
export IMAGE_TAG=$3

envsubst < ./deployment.yaml.tmpl > deployment.yaml
envsubst < ./service.yaml.tmpl > service.yaml
envsubst < ./ingress.yaml.tmpl > ingress.yaml