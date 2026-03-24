import logging

logger = logging.getLogger(__name__)


def send_alert_via_ses(
    ses_client,
    sender_email_address: str,
    recipient_email_addresses: list[str],
    subject: str,
    body_html: str,
) -> None:
    """Sends an HTML email notification via AWS SES to all recipient addresses."""
    ses_client.send_email(
        FromEmailAddress=sender_email_address,
        Destination={"ToAddresses": recipient_email_addresses},
        Content={
            "Simple": {
                "Subject": {"Data": subject, "Charset": "UTF-8"},
                "Body": {"Html": {"Data": body_html, "Charset": "UTF-8"}},
            }
        },
    )
    logger.info("Alert email sent via SES to %d recipient(s)", len(recipient_email_addresses))


def send_alert_via_sns(
    sns_client,
    sns_topic_arn: str,
    subject: str,
    message_body: str,
) -> None:
    """Publishes a plain-text alert message to an SNS topic."""
    sns_client.publish(
        TopicArn=sns_topic_arn,
        Subject=subject,
        Message=message_body,
    )
    logger.info("Alert published to SNS topic")
