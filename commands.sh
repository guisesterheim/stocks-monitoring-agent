#!/bin/bash

# ============================================================
# Pipeline Commands
# ============================================================

# ---- AWS Authentication ------------------------------------

AWS_CREDENTIALS_CACHE_DIR="/Users/guisester/.aws/login/cache"

# Find the single credentials file in the cache folder
AWS_CREDENTIALS_FILE=$(ls "$AWS_CREDENTIALS_CACHE_DIR"/*.json 2>/dev/null | head -n 1)

if [ -z "$AWS_CREDENTIALS_FILE" ]; then
  echo "ERROR: No credentials file found in $AWS_CREDENTIALS_CACHE_DIR"
  echo "Please authenticate to AWS first."
fi

# Export credentials from the cached file
export AWS_ACCESS_KEY_ID=$(cat "$AWS_CREDENTIALS_FILE" | jq -r .accessToken.accessKeyId)
export AWS_SECRET_ACCESS_KEY=$(cat "$AWS_CREDENTIALS_FILE" | jq -r .accessToken.secretAccessKey)
export AWS_SESSION_TOKEN=$(cat "$AWS_CREDENTIALS_FILE" | jq -r .accessToken.sessionToken)

# Verify the credentials are valid and the CLI is authenticated
echo "Verifying AWS authentication..."
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$AWS_ACCOUNT_ID" ]; then
  echo "ERROR: AWS authentication failed. Credentials may be expired."
  echo "Please re-authenticate and try again."
fi

echo "Authenticated to AWS account: $AWS_ACCOUNT_ID"

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
