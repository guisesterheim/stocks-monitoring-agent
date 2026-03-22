use anyhow::{Context, Result};
use aws_sdk_secretsmanager::Client as SecretsManagerClient;

/// Fetches a secret string value from AWS Secrets Manager by secret name
pub async fn fetch_secret_value(
    secrets_client: &SecretsManagerClient,
    secret_name: &str,
) -> Result<String> {
    let response = secrets_client
        .get_secret_value()
        .secret_id(secret_name)
        .send()
        .await
        .with_context(|| format!("Failed to fetch secret '{}'", secret_name))?;

    response
        .secret_string()
        .map(|secret_string| secret_string.to_string())
        .with_context(|| format!("Secret '{}' has no string value", secret_name))
}
