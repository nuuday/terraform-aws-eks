#!/bin/env bash

usage() {
    echo "Usage: $0 [-r AWS_REGION] [-k KUBE_CONFIG] [-w]" 1>&2; exit 1;
}

# Attempt to read defaults from env vars
AWS_REGION=$AWS_DEFAULT_REGION
KUBE_CONFIG=$KUBECONFIG

CLEAN=''
WAIT=''
TMP_PATH=$(mktemp -d)
VPC_DEPLOYMENT_NAME='deployment/vpc-admission-webhook-deployment'
VPC_NAMESPACE='kube-system'

while getopts ':r:k:w:' o; do
    case "${o}" in
        r)
            REGION=${OPTARG} ;;
        k)
            KUBE_CONFIG=${OPTARG} ;;
        w)
            WAIT='true'
    esac
done

if ! [ -z ${AWS_REGION+''} ]; then
    usage
fi

if ! [ -z ${KUBE_CONFIG+''} ]; then
    usage
fi

echo "Assuming region '$AWS_REGION'" 1>&2
echo "Using kubeconfig '$KUBE_CONFIG'" 1>&2
echo "Using temporary directory '$TMP_PATH'" 1>&2

# Download scripts and manifests from
# https://docs.aws.amazon.com/eks/latest/userguide/windows-support.html

echo "Downloading required AWS scripts and manifests" 1>&2
curl -s -o $TMP_PATH/webhook-create-signed-cert.sh https://amazon-eks.s3-us-west-2.amazonaws.com/manifests/$AWS_REGION/vpc-admission-webhook/latest/webhook-create-signed-cert.sh
curl -s -o $TMP_PATH/webhook-patch-ca-bundle.sh https://amazon-eks.s3-us-west-2.amazonaws.com/manifests/$AWS_REGION/vpc-admission-webhook/latest/webhook-patch-ca-bundle.sh
curl -s -o $TMP_PATH/vpc-admission-webhook-deployment.yaml https://amazon-eks.s3-us-west-2.amazonaws.com/manifests/$AWS_REGION/vpc-admission-webhook/latest/vpc-admission-webhook-deployment.yaml

chmod +x $TMP_PATH/webhook-create-signed-cert.sh $TMP_PATH/webhook-patch-ca-bundle.sh

# Run scripts and apply manifests from above section

echo "Applying manifests using kube config '$KUBE_CONFIG'" 1>&2
KUBECONFIG=$KUBE_CONFIG kubectl apply -f https://amazon-eks.s3-us-west-2.amazonaws.com/manifests/$AWS_REGION/vpc-resource-controller/latest/vpc-resource-controller.yaml

KUBECONFIG=$KUBE_CONFIG $TMP_PATH/webhook-create-signed-cert.sh

cat $TMP_PATH/vpc-admission-webhook-deployment.yaml | $TMP_PATH/webhook-patch-ca-bundle.sh >$TMP_PATH/vpc-admission-webhook.yaml
KUBECONFIG=$KUBE_CONFIG kubectl apply -f $TMP_PATH/vpc-admission-webhook.yaml

echo "Removing $TMP_PATH" 1>&2
rm -rf $TMP_PATH

if [ -z "${WAIT}" ]; then
    echo "Waiting for $VPC_DEPLOYMENT_NAME to complete..." 1>&2
    KUBECONFIG=$KUBE_CONFIG kubectl wait --for=condition=Available -n $VPC_NAMESPACE $VPC_DEPLOYMENT_NAME
fi

