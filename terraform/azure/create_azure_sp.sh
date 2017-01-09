#!/bin/bash
#This script will create a new Service Principal using the given 
#subscription id and name. Make sure you are logged in to azure first
#with az login 


ARM_SUBSCRIPTION_ID=$1
SP_NAME=$2

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 2 ] || die "2 argument required (Subscription Id and Name), $# provided"

az account set --subscription=$ARM_SUBSCRIPTION_ID 
az ad sp create-for-rbac --role="Contributor" --name "${SP_NAME}" --scopes="/subscriptions/${ARM_SUBSCRIPTION_ID}"
