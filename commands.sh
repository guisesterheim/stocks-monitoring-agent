#!/bin/bash

# ============================================================
# Pipeline Commands
# ============================================================
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)

# ---- CloudFormation ----------------------------------------

# Deploy the Terraform state bootstrap bucket
aws cloudformation deploy \
  --template-file cloudformation/terraform-state-bucket.yaml \
  --stack-name terraform-state-bootstrap \
  --parameter-overrides BucketName="${AWS_ACCOUNT_ID}-stocks-monitor-state-files"

# ---- Terraform (first apply — creates ECR repos before building images) ----

terraform -chdir=terraform init \
  -backend-config="bucket=${AWS_ACCOUNT_ID}-stocks-monitor-state-files" \
  -backend-config="region=us-east-1"

terraform -chdir=terraform plan

terraform -chdir=terraform apply \
  -var-file="terraform.tfvars" \
  -target="module.ecr" \
  -target="module.lambda" \
  -auto-approve

# ---- Agent: Docker Build & Push ----------------------------

ECR_AGENT_URL=$(terraform -chdir=terraform output -raw ecr_repository_url)

aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin "$ECR_AGENT_URL"

docker buildx build \
  --platform linux/arm64 \
  --provenance=false \
  --output type=image,name="${ECR_AGENT_URL}:latest",push=true \
  stocks_monitor_agent/

# ---- Lambda Invoker: Docker Build & Push -------------------

ECR_LAMBDA_URL=$(terraform -chdir=terraform output -raw lambda_invoker_ecr_repository_url)

aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin "$ECR_LAMBDA_URL"

docker buildx build \
  --platform linux/arm64 \
  --provenance=false \
  --output type=image,name="${ECR_LAMBDA_URL}:latest",push=true \
  lambda_invoker/

# ---- Terraform (full apply — deploys all remaining resources) --------------

terraform -chdir=terraform apply \
  -var-file="terraform.tfvars" \
  -auto-approve
