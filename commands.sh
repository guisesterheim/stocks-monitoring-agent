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
  -target="module.ecr"

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
  -var-file="terraform.tfvars"


PAYLOAD=$(echo -n '{"prompt": "run"}' | base64)
aws bedrock-agentcore invoke-agent-runtime \
  --agent-runtime-arn "arn:aws:bedrock-agentcore:us-east-1:959689756284:runtime/StocksMonitorRuntime-Qf8ct582B9" \
  --runtime-session-id "manual-StocksMonitorRuntime-00001" \
  --payload "$PAYLOAD" \
  output.bin


docker run -p 8080:8080 \
  -e RECIPIENT_EMAIL_ADDRESSES="[\"exmokvra@gmail.com\"]" \
  -e AWS_REGION_NAME="us-east-1" \
  -e CLAUDE_MODEL_ID="amazon.nova-micro-v1:0" \
  -e DAILY_DROP_THRESHOLD_PERCENT="2" \
  -e SENDER_EMAIL_ADDRESS="stocks-agent@sesterheim.com.br" \
  -e SNS_TOPIC_ARN="arn:aws:sns:us-east-1:959689756284:stocks-monitor-alerts" \
  -e STOCKS_TABLE_NAME="stocks-monitor-stocks-list" \
  -e USE_SES="false" \
  -e WEEKLY_DROP_THRESHOLD_PERCENT="5" \
  959689756284.dkr.ecr.us-east-1.amazonaws.com/stocks-monitor-agent:latest