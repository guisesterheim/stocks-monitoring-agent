use anyhow::Result;
use axum::http::StatusCode;
use axum::Json;
use serde_json::{json, Value};
use tracing::{error, info};

use crate::controller::alert_evaluator::evaluate_stock_alerts;
use crate::model::config::AgentConfig;
use crate::model::stock_data::StockClosingPrice;
use crate::repository::{
    browser_repository, dynamodb_repository, notification_repository, secrets_repository,
};

/// Handles the HTTP POST /invoke request from AgentCore Runtime (triggered by EventBridge)
pub async fn handle_invocation(
    Json(_payload): Json<Value>,
) -> Result<Json<Value>, StatusCode> {
    run_stocks_monitor_pipeline()
        .await
        .map(|_| Json(json!({ "status": "ok" })))
        .map_err(|error| {
            error!("Pipeline failed: {:?}", error);
            StatusCode::INTERNAL_SERVER_ERROR
        })
}

/// Orchestrates the full pipeline:
/// 1. Load config and secrets
/// 2. Fetch monitored stocks from DynamoDB
/// 3. For each stock: fetch current price via AgentCore Browser
/// 4. Evaluate daily and weekly alert rules
/// 5. Save today's closing price to DynamoDB
/// 6. Send notifications for triggered alerts
async fn run_stocks_monitor_pipeline() -> Result<()> {
    let config = AgentConfig::load_from_environment()?;

    let aws_sdk_config = aws_config::load_from_env().await;
    let secrets_client = aws_sdk_secretsmanager::Client::new(&aws_sdk_config);
    let dynamodb_client = aws_sdk_dynamodb::Client::new(&aws_sdk_config);
    let ses_client = aws_sdk_sesv2::Client::new(&aws_sdk_config);
    let http_client = reqwest::Client::new();

    let claude_api_key = secrets_repository::fetch_secret_value(
        &secrets_client,
        &config.claude_api_key_secret_name,
    )
    .await?;

    let browser_endpoint_url = std::env::var("AGENTCORE_BROWSER_ENDPOINT_URL")
        .unwrap_or_else(|_| "http://localhost:9000/browser".to_string());

    let monitored_stocks = dynamodb_repository::fetch_monitored_stocks(
        &dynamodb_client,
        &config.stocks_table_name,
    )
    .await?;

    info!("Monitoring {} stocks", monitored_stocks.len());

    let today = chrono_today_date_string();

    for stock in &monitored_stocks {
        let current_price = browser_repository::fetch_current_price_via_browser(
            &http_client,
            &browser_endpoint_url,
            &stock.ticker,
        )
        .await?;

        let recent_prices = dynamodb_repository::fetch_recent_closing_prices(
            &dynamodb_client,
            &config.prices_table_name,
            &stock.ticker,
            5,
        )
        .await?;

        let alert = evaluate_stock_alerts(
            &stock.ticker,
            current_price,
            &recent_prices,
            config.daily_drop_threshold_percent,
            config.weekly_drop_threshold_percent,
        );

        dynamodb_repository::save_closing_price(
            &dynamodb_client,
            &config.prices_table_name,
            &StockClosingPrice {
                ticker: stock.ticker.clone(),
                date: today.clone(),
                closing_price: current_price,
            },
        )
        .await?;

        if alert.daily_alert_triggered || alert.weekly_alert_triggered {
            let subject = format!("Stock Alert: {}", alert.ticker);
            let body_html = build_alert_email_body(&alert, &claude_api_key, &config, &http_client).await?;

            notification_repository::send_email_alert_via_ses(
                &ses_client,
                &config.sender_email_address,
                &config.recipient_email_addresses,
                &subject,
                &body_html,
            )
            .await?;

            info!("Alert sent for {}", alert.ticker);
        }
    }

    Ok(())
}

/// Calls Claude API to generate a human-readable alert email body
async fn build_alert_email_body(
    alert: &crate::model::stock_data::StockAlertEvaluation,
    claude_api_key: &str,
    config: &AgentConfig,
    http_client: &reqwest::Client,
) -> Result<String> {
    let _ = (alert, claude_api_key, config, http_client);
    // TODO: implement Claude API call to generate email body
    todo!("Implement Claude API call for email body generation")
}

/// Returns today's date as a string in YYYY-MM-DD format using system time
fn chrono_today_date_string() -> String {
    use std::time::{SystemTime, UNIX_EPOCH};
    let seconds_since_epoch = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("System time is before Unix epoch")
        .as_secs();
    let days_since_epoch = seconds_since_epoch / 86400;
    let (year, month, day) = days_since_epoch_to_ymd(days_since_epoch);
    format!("{:04}-{:02}-{:02}", year, month, day)
}

/// Converts days since Unix epoch to (year, month, day)
fn days_since_epoch_to_ymd(days: u64) -> (u64, u64, u64) {
    let mut remaining_days = days + 719468;
    let era = remaining_days / 146097;
    let day_of_era = remaining_days % 146097;
    let year_of_era = (day_of_era - day_of_era / 1460 + day_of_era / 36524 - day_of_era / 146096) / 365;
    let year = year_of_era + era * 400;
    let day_of_year = day_of_era - (365 * year_of_era + year_of_era / 4 - year_of_era / 100);
    let month_prime = (5 * day_of_year + 2) / 153;
    let day = day_of_year - (153 * month_prime + 2) / 5 + 1;
    let month = if month_prime < 10 { month_prime + 3 } else { month_prime - 9 };
    remaining_days = if month <= 2 { 1 } else { 0 };
    (year + remaining_days, month, day)
}
