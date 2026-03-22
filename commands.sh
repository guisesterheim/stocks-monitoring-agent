#!/bin/bash

# ============================================================
# Pipeline Commands
# ============================================================

# ---- CloudFormation ----------------------------------------

# Deploy the Terraform state bootstrap bucket
aws cloudformation deploy \
  --template-file cloudformation/terraform-state-bucket.yaml \
  --stack-name terraform-state-bootstrap \
  --parameter-overrides BucketName="${AWS_ACCOUNT_ID}-stocks-monitor-state-files"

# ---- Terraform (first apply — creates ECR before building image) -----------

terraform -chdir=terraform init \
  -backend-config="bucket=${AWS_ACCOUNT_ID}-stocks-monitor-state-files" \
  -backend-config="region=us-east-1"

terraform -chdir=terraform apply \
  -var-file="terraform.tfvars" \
  -target="module.ecr" \
  -auto-approve

# ---- Docker Build & Push -----------------------------------

ECR_REPOSITORY_URL=$(terraform -chdir=terraform output -raw ecr_repository_url)

aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin "$ECR_REPOSITORY_URL"

docker build -t stocks-monitor-agent stocks_monitor_agent/

docker tag stocks-monitor-agent:latest "${ECR_REPOSITORY_URL}:latest"

docker push "${ECR_REPOSITORY_URL}:latest"

# ---- Terraform (full apply — deploys all remaining resources) --------------

terraform -chdir=terraform apply \
  -var-file="terraform.tfvars" \
  -var="container_image_uri=${ECR_REPOSITORY_URL}:latest" \
  -auto-approve
