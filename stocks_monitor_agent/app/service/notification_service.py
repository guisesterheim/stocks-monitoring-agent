import logging

from app.model.config import AgentConfig
from app.model.stock_data import StockMarketData
from app.repository import notification_repository
from app.service import email_service

logger = logging.getLogger(__name__)


def send_daily_report(
    config: AgentConfig,
    ses_client,
    sns_client,
    stocks: list[StockMarketData],
) -> None:
    """Sends the daily report with all monitored stocks via SES or SNS."""
    subject = f"Stock Monitor Daily Report: {len(stocks)} ticker(s)"

    if config.use_ses:
        body_html = email_service.build_alert_email_html(stocks, config.stock_quote_url_template)
        notification_repository.send_alert_via_ses(
            ses_client,
            config.sender_email_address,
            config.recipient_email_addresses,
            subject,
            body_html,
        )
    else:
        message_body = email_service.build_sns_plain_text_message(stocks, config.stock_quote_url_template)
        notification_repository.send_alert_via_sns(
            sns_client,
            config.sns_topic_arn,
            subject,
            message_body,
        )

    logger.info("Notifications sent for %d stock(s)", len(stocks))
