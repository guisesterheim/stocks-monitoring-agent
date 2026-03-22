#!/bin/bash

AWS_CREDENTIALS_CACHE_DIR="/Users/guisester/.aws/login/cache"
AWS_CLI_CREDENTIALS_FILE_NAME="/Users/guisester/.aws/credentials"

rm -f ${AWS_CLI_CREDENTIALS_FILE_NAME}
aws login

# ---- AWS Authentication ------------------------------------
AWS_CREDENTIALS_FILE=$(ls "$AWS_CREDENTIALS_CACHE_DIR"/*.json 2>/dev/null | head -n 1)

if [ -z "$AWS_CREDENTIALS_FILE" ]; then
  echo "ERROR: No credentials file found in $AWS_CREDENTIALS_CACHE_DIR"
  echo "Please authenticate to AWS first."
  exit 1
fi

rm -f ${AWS_CLI_CREDENTIALS_FILE_NAME}

export AWS_ACCESS_KEY_ID=$(cat "$AWS_CREDENTIALS_FILE" | jq -r .accessToken.accessKeyId)
export AWS_SECRET_ACCESS_KEY=$(cat "$AWS_CREDENTIALS_FILE" | jq -r .accessToken.secretAccessKey)
export AWS_SESSION_TOKEN=$(cat "$AWS_CREDENTIALS_FILE" | jq -r .accessToken.sessionToken)

echo "[default]" > ${AWS_CLI_CREDENTIALS_FILE_NAME}
echo "aws_access_key_id=${AWS_ACCESS_KEY_ID}" >> ${AWS_CLI_CREDENTIALS_FILE_NAME}
echo "aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}" >> ${AWS_CLI_CREDENTIALS_FILE_NAME}
echo "aws_session_token=${AWS_SESSION_TOKEN}" >> ${AWS_CLI_CREDENTIALS_FILE_NAME}

echo "Verifying AWS authentication..."
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$AWS_ACCOUNT_ID" ]; then
  echo "ERROR: AWS authentication failed. Credentials may be expired."
  echo "Please re-authenticate and try again."
  exit 1
fi

echo "Authenticated to AWS account: $AWS_ACCOUNT_ID"
