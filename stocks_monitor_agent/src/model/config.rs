use anyhow::{Context, Result};

/// All runtime configuration loaded from environment variables at startup
#[derive(Debug, Clone)]
pub struct AgentConfig {
    pub claude_api_key_secret_name: String,
    pub stocks_table_name: String,
    pub prices_table_name: String,
    pub agentcore_memory_id: String,
    pub sns_topic_arn: String,
    pub use_ses: bool,
    pub sender_email_address: String,
    pub recipient_email_addresses: Vec<String>,
    pub daily_drop_threshold_percent: f64,
    pub weekly_drop_threshold_percent: f64,
    pub claude_model_id: String,
    pub aws_region: String,
}

impl AgentConfig {
    /// Loads all configuration from environment variables.
    /// Returns an error if any required variable is missing.
    pub fn load_from_environment() -> Result<Self> {
        let recipient_emails_json = std::env::var("RECIPIENT_EMAIL_ADDRESSES")
            .context("RECIPIENT_EMAIL_ADDRESSES env var is missing")?;

        let recipient_email_addresses: Vec<String> =
            serde_json::from_str(&recipient_emails_json)
                .context("Failed to parse RECIPIENT_EMAIL_ADDRESSES as JSON array")?;

        let use_ses = std::env::var("USE_SES")
            .unwrap_or_else(|_| "false".to_string())
            == "true";

        let sender_email_address = std::env::var("SENDER_EMAIL_ADDRESS")
            .unwrap_or_default();

        Ok(Self {
            claude_api_key_secret_name: std::env::var("CLAUDE_API_KEY_SECRET_NAME")
                .context("CLAUDE_API_KEY_SECRET_NAME env var is missing")?,
            stocks_table_name: std::env::var("STOCKS_TABLE_NAME")
                .context("STOCKS_TABLE_NAME env var is missing")?,
            prices_table_name: std::env::var("PRICES_TABLE_NAME")
                .context("PRICES_TABLE_NAME env var is missing")?,
            agentcore_memory_id: std::env::var("AGENTCORE_MEMORY_ID")
                .context("AGENTCORE_MEMORY_ID env var is missing")?,
            sns_topic_arn: std::env::var("SNS_TOPIC_ARN")
                .context("SNS_TOPIC_ARN env var is missing")?,
            use_ses,
            sender_email_address,
            recipient_email_addresses,
            daily_drop_threshold_percent: std::env::var("DAILY_DROP_THRESHOLD_PERCENT")
                .context("DAILY_DROP_THRESHOLD_PERCENT env var is missing")?
                .parse::<f64>()
                .context("DAILY_DROP_THRESHOLD_PERCENT must be a number")?,
            weekly_drop_threshold_percent: std::env::var("WEEKLY_DROP_THRESHOLD_PERCENT")
                .context("WEEKLY_DROP_THRESHOLD_PERCENT env var is missing")?
                .parse::<f64>()
                .context("WEEKLY_DROP_THRESHOLD_PERCENT must be a number")?,
            claude_model_id: std::env::var("CLAUDE_MODEL_ID")
                .context("CLAUDE_MODEL_ID env var is missing")?,
            aws_region: std::env::var("AWS_REGION_NAME")
                .context("AWS_REGION_NAME env var is missing")?,
        })
    }
}
