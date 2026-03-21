#!/bin/bash

# ============================================================
# Pipeline Commands
# ============================================================

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# ---- CloudFormation ----------------------------------------

# Deploy the Terraform state bootstrap bucket
aws cloudformation deploy \
  --template-file cloudformation/terraform-state-bucket.yaml \
  --stack-name terraform-state-bootstrap \
  --parameter-overrides BucketName="${AWS_ACCOUNT_ID}-stocks-monitor-state-files"

# ---- Rust Build --------------------------------------------

# Install the cross-compilation target for ARM64 Lambda (provided.al2023)
rustup target add aarch64-unknown-linux-musl

# Build the Rust Lambda binary for ARM64
cargo build \
  --release \
  --target aarch64-unknown-linux-musl \
  --manifest-path stocks_monitor_agent/Cargo.toml

# Package the binary into a zip file for Lambda deployment
cp stocks_monitor_agent/target/aarch64-unknown-linux-musl/release/bootstrap bootstrap
zip lambda.zip bootstrap
rm bootstrap

# ---- Terraform ---------------------------------------------

# Initialize Terraform (connects to S3 remote state backend)
terraform -chdir=terraform init \
  -backend-config="bucket=${AWS_ACCOUNT_ID}-stocks-monitor-state-files" \
  -backend-config="region=us-east-1"

# Preview infrastructure changes
terraform -chdir=terraform plan -var-file="terraform.tfvars"

# Apply infrastructure changes
terraform -chdir=terraform apply -var-file="terraform.tfvars" -auto-approve

# ---- Deploy Lambda -----------------------------------------

# Update the Lambda function code with the newly built binary
aws lambda update-function-code \
  --function-name stocks-monitor-agent \
  --zip-file fileb://lambda.zip \
  --region us-east-1
