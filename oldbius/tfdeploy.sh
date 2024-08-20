#!/usr/bin/env bash
set -e

export NCP_TOKEN=$(ncp iam create-token)
export NCP_CLOUD_ID=$(ncp config get cloud-id)
export NCP_FOLDER_ID=$(ncp config get folder-id)

VERB=${1}
if [ -z "${VERB}" ]; then
    echo "Error: missing VERB paramter"
    echo "Usage: ./deploy.sh <VERB>"
    exit 1
fi

if [ ${VERB} == "init" ]; then
  read -p "Enter the bucket name: " bucket
  read -p "Enter the key: " key
  read -p "Enter the region: " region
  read -p "Enter the AWS_ACCESS_KEY_ID: " aws_key
  read -p "Enter the AWS_SECRET_ACCESS_KEY: " aws_secret

  echo "Backend-config for S3 added."
  echo "Bucket: $bucket"
  echo "Key: $key"
  echo "Region: $region"

  echo "export AWS_ACCESS_KEY_ID=$aws_key" > .env
  echo "export AWS_SECRET_ACCESS_KEY=$aws_secret" >> .env
  source .env
  
  terraform init \
      -backend-config="bucket=$bucket" \
      -backend-config="key=$key" \
      -backend-config="region=$region" \
      -backend-config="endpoint=storage.nemax.nebius.cloud" \
      -backend-config="skip_region_validation=true" \
      -backend-config="skip_credentials_validation=true"
fi

if [ ${VERB} == "plan" ]; then
  source .env
  terraform plan -input=false
fi
if [ ${VERB} == "apply" ]; then
  source .env
  terraform apply -input=false
fi
if [ ${VERB} == "destroy" ]; then
    source .env
    terraform -chdir="./terraform/oldbius" destroy -input=false
fi
if [ ${VERB} == "patch" ]; then
    source .env
    terraform -chdir="./terraform/oldbius" workspace select ${WORKSPACE}
    terraform -chdir="./terraform/oldbius" state pull > ./terraform/oldbius/terraform.tfstate
    jq '.serial |= . + 1 |(.resources[] | select(.type == "nebius_client_config").instances[].attributes) |= del(.iam_token)' ./terraform/oldbius/terraform.tfstate > ./terraform/oldbius/terraform.tfstate.new
    terraform -chdir="./terraform/oldbius" state push terraform.tfstate.new
    rm ./terraform/oldbius/terraform.tfstate ./terraform/oldbius/terraform.tfstate.new
fi

echo "finished"
