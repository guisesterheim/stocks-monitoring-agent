use anyhow::{Result};
use axum::http::StatusCode;
use axum::Json;
use serde_json::{json, Value};
use tracing::{error, info};

use crate::controller::alert_evaluator::evaluate_stock_alerts;
use crate::model::config::AgentConfig;
use crate::model::email_template::build_alert_email_html;
use crate::model::stock_data::StockAlertEvaluation;
use crate::repository::{browser_repository, dynamodb_repository, notification_repository};

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
/// 1. Load config from environment
/// 2. Fetch monitored stocks from DynamoDB
/// 3. For each stock: fetch market data from CNBC via AgentCore Browser + Claude
/// 4. Evaluate daily and weekly alert rules
/// 5. If any alerts triggered: build email and send via SES or SNS
async fn run_stocks_monitor_pipeline() -> Result<()> {
    let config = AgentConfig::load_from_environment()?;

    let aws_sdk_config = aws_config::defaults(aws_config::BehaviorVersion::latest()).load().await;
    let dynamodb_client = aws_sdk_dynamodb::Client::new(&aws_sdk_config);
    let bedrock_client = aws_sdk_bedrockruntime::Client::new(&aws_sdk_config);
    let ses_client = aws_sdk_sesv2::Client::new(&aws_sdk_config);
    let sns_client = aws_sdk_sns::Client::new(&aws_sdk_config);
    let http_client = reqwest::Client::new();

    let browser_endpoint_url = config.agentcore_browser_endpoint_url.clone();

    // TODO: remove — debug probe to confirm execution started
    send_diagnostic_notification(&config, &ses_client, &sns_client, "start").await?;

    let monitored_stocks = dynamodb_repository::fetch_monitored_stocks(
        &dynamodb_client,
        &config.stocks_table_name,
    )
    .await?;

    info!("Monitoring {} stocks", monitored_stocks.len());

    let mut triggered_alerts = Vec::new();

    for stock in &monitored_stocks {
        let market_data = browser_repository::fetch_stock_market_data_from_cnbc(
            &http_client,
            &bedrock_client,
            &browser_endpoint_url,
            &config.claude_model_id,
            &stock.ticker,
        )
        .await?;

        let alert = evaluate_stock_alerts(
            market_data,
            config.daily_drop_threshold_percent,
            config.weekly_drop_threshold_percent,
        );

        if alert.daily_alert_triggered || alert.weekly_alert_triggered {
            info!(
                ticker = %alert.ticker,
                daily = alert.market_data.daily_change_percent,
                five_day = alert.market_data.five_day_change_percent,
                "Alert triggered"
            );
            triggered_alerts.push(alert);
        }
    }

    if triggered_alerts.is_empty() {
        info!("No alerts triggered for this run");
        // TODO: remove — debug probe to confirm execution completed
        send_diagnostic_notification(&config, &ses_client, &sns_client, "end").await?;
        return Ok(());
    }

    send_notifications(&config, &ses_client, &sns_client, &triggered_alerts).await?;

    // TODO: remove — debug probe to confirm execution completed
    send_diagnostic_notification(&config, &ses_client, &sns_client, "end").await?;

    Ok(())
}

/// Sends notifications for all triggered alerts via SES or SNS based on config
async fn send_notifications(
    config: &AgentConfig,
    ses_client: &aws_sdk_sesv2::Client,
    sns_client: &aws_sdk_sns::Client,
    triggered_alerts: &[StockAlertEvaluation],
) -> Result<()> {
    let subject = format!("Stock Alert: {} ticker(s) triggered", triggered_alerts.len());

    if config.use_ses {
        let body_html = build_alert_email_html(triggered_alerts)?;
        notification_repository::send_alert_via_ses(
            ses_client,
            &config.sender_email_address,
            &config.recipient_email_addresses,
            &subject,
            &body_html,
        )
        .await?;
    } else {
        let message_body = build_sns_plain_text_message(triggered_alerts);
        notification_repository::send_alert_via_sns(
            sns_client,
            &config.sns_topic_arn,
            &subject,
            &message_body,
        )
        .await?;
    }

    info!("Notifications sent for {} alert(s)", triggered_alerts.len());
    Ok(())
}

/// TODO: remove — sends a diagnostic ping ("start" or "end") to confirm execution
async fn send_diagnostic_notification(
    config: &AgentConfig,
    ses_client: &aws_sdk_sesv2::Client,
    sns_client: &aws_sdk_sns::Client,
    label: &str,
) -> Result<()> {
    let subject = format!("Stocks Monitor Agent — {}", label);
    let body = format!("Agent execution: {}", label);

    if config.use_ses {
        notification_repository::send_alert_via_ses(
            ses_client,
            &config.sender_email_address,
            &config.recipient_email_addresses,
            &subject,
            &body,
        )
        .await?;
    } else {
        notification_repository::send_alert_via_sns(
            sns_client,
            &config.sns_topic_arn,
            &subject,
            &body,
        )
        .await?;
    }

    info!("Diagnostic notification sent: {}", label);
    Ok(())
}

/// Builds a plain-text message body for SNS notifications
fn build_sns_plain_text_message(alerts: &[StockAlertEvaluation]) -> String {
    let lines: Vec<String> = alerts
        .iter()
        .map(|alert| {
            format!(
                "{}: ${:.2} | Today: {:.2}% | 5d: {:.2}% | 30d: {:.2}% | https://www.cnbc.com/quotes/{}",
                alert.ticker,
                alert.market_data.current_price,
                alert.market_data.daily_change_percent,
                alert.market_data.five_day_change_percent,
                alert.market_data.thirty_day_change_percent,
                alert.ticker,
            )
        })
        .collect();

    lines.join("\n")
}
