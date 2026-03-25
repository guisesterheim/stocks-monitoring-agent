import logging
import os

import boto3

from app.controller.alert_evaluator import evaluate_stock_alerts
from app.model.config import AgentConfig
from app.model.stock_data import StockAlertEvaluation
from app.repository import browser_repository, dynamodb_repository, notification_repository

logger = logging.getLogger(__name__)


def run_stocks_monitor_pipeline() -> None:
    """
    Orchestrates the full pipeline:
    1. Load config from environment
    2. Fetch monitored stocks from DynamoDB
    3. For each stock: fetch market data from CNBC via AgentCore Browser + Claude
    4. Evaluate daily and weekly alert rules
    5. If any alerts triggered: build email and send via SES or SNS
    """
    logger.info("Pipeline started")

    config = AgentConfig()

    session = boto3.Session(region_name=config.aws_region)
    dynamodb_client = session.client("dynamodb")
    bedrock_client = session.client("bedrock-runtime")
    ses_client = session.client("sesv2")
    sns_client = session.client("sns")

    monitored_stocks = dynamodb_repository.fetch_monitored_stocks(
        dynamodb_client, config.stocks_table_name
    )
    logger.info("Monitoring %d stocks", len(monitored_stocks))

    all_evaluations: list[StockAlertEvaluation] = []
    triggered_alerts: list[StockAlertEvaluation] = []

    for stock in monitored_stocks:
        market_data = browser_repository.fetch_stock_market_data_from_cnbc(
            bedrock_client=bedrock_client,
            aws_region=config.aws_region,
            claude_model_id=config.claude_model_id,
            ticker=stock.ticker,
        )

        alert = evaluate_stock_alerts(
            market_data,
            config.daily_drop_threshold_percent,
            config.weekly_drop_threshold_percent,
        )

        all_evaluations.append(alert)

        if alert.daily_alert_triggered or alert.weekly_alert_triggered:
            logger.info(
                "Alert triggered for %s — daily: %.2f%%, 5d: %.2f%%",
                alert.ticker,
                alert.market_data.daily_change_percent,
                alert.market_data.five_day_change_percent,
            )
            triggered_alerts.append(alert)

    logger.info("%d of %d stocks triggered alerts", len(triggered_alerts), len(all_evaluations))
    _send_notifications(config, ses_client, sns_client, all_evaluations, triggered_alerts)


def _send_notifications(
    config: AgentConfig,
    ses_client,
    sns_client,
    all_evaluations: list[StockAlertEvaluation],
    triggered_alerts: list[StockAlertEvaluation],
) -> None:
    """Sends daily report with all stocks. Triggered alerts are highlighted."""
    subject = f"Stock Monitor Daily Report: {len(triggered_alerts)} ticker(s) triggered"

    if config.use_ses:
        body_html = _build_alert_email_html(all_evaluations)
        notification_repository.send_alert_via_ses(
            ses_client,
            config.sender_email_address,
            config.recipient_email_addresses,
            subject,
            body_html,
        )
    else:
        message_body = _build_sns_plain_text_message(all_evaluations)
        notification_repository.send_alert_via_sns(
            sns_client,
            config.sns_topic_arn,
            subject,
            message_body,
        )

    logger.info("Notifications sent for %d stock(s)", len(all_evaluations))


def _build_alert_email_html(alerts: list[StockAlertEvaluation]) -> str:
    """Loads the HTML email template and injects the stock tiles and timestamp."""
    from datetime import datetime, timezone
    template_path = os.environ.get("EMAIL_TEMPLATE_PATH", "/app/templates/alert_email.html")
    with open(template_path, "r", encoding="utf-8") as f:
        template = f.read()

    timestamp = datetime.now(timezone.utc).strftime("%B %d, %Y %H:%M UTC")
    tiles = "".join(_build_stock_tile_html(alert) for alert in alerts)
    return template.replace("{{STOCK_TILES}}", tiles).replace("{{TIMESTAMP}}", timestamp)


def _build_stock_tile_html(alert: StockAlertEvaluation) -> str:
    """Builds a single stock tile HTML block for one alert evaluation."""
    direction_class = "up" if alert.market_data.daily_change_percent >= 0 else "down"
    daily_sign = "+" if alert.market_data.daily_change_percent >= 0 else "-"
    five_day_sign = "+" if alert.market_data.five_day_change_percent >= 0 else "-"
    thirty_day_sign = "+" if alert.market_data.thirty_day_change_percent >= 0 else "-"

    return (
        f'<div class="tile {direction_class}">\n'
        f'  <div class="ticker">{alert.ticker}</div>\n'
        f'  <div class="price">${alert.market_data.current_price:.2f}</div>\n'
        f'  <div class="change">Today: {daily_sign}{abs(alert.market_data.daily_change_percent):.2f}%</div>\n'
        f'  <div class="change">5 days: {five_day_sign}{abs(alert.market_data.five_day_change_percent):.2f}%</div>\n'
        f'  <div class="change">30 days: {thirty_day_sign}{abs(alert.market_data.thirty_day_change_percent):.2f}%</div>\n'
        f'  <a href="https://www.cnbc.com/quotes/{alert.ticker}" target="_blank">View on CNBC →</a>\n'
        f'</div>\n'
    )


def _build_sns_plain_text_message(alerts: list[StockAlertEvaluation]) -> str:
    """Builds a plain-text message body for SNS notifications."""
    lines = []
    for alert in alerts:
        lines.append(
            f"{alert.ticker}: ${alert.market_data.current_price:.2f} | "
            f"Today: {alert.market_data.daily_change_percent:.2f}% | "
            f"5d: {alert.market_data.five_day_change_percent:.2f}% | "
            f"30d: {alert.market_data.thirty_day_change_percent:.2f}% | "
            f"https://www.cnbc.com/quotes/{alert.ticker}"
        )
    return "\n".join(lines)
