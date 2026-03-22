use anyhow::{Context, Result};
use aws_sdk_sesv2::{
    types::{Body, Content, Destination, EmailContent, Message},
    Client as SesClient,
};
use aws_sdk_sns::Client as SnsClient;

/// Sends an HTML email notification via AWS SES to all recipient addresses
pub async fn send_alert_via_ses(
    ses_client: &SesClient,
    sender_email_address: &str,
    recipient_email_addresses: &[String],
    subject: &str,
    body_html: &str,
) -> Result<()> {
    let destination = Destination::builder()
        .set_to_addresses(Some(recipient_email_addresses.to_vec()))
        .build();

    let subject_content = Content::builder()
        .data(subject)
        .charset("UTF-8")
        .build()
        .context("Failed to build email subject")?;

    let body_content = Content::builder()
        .data(body_html)
        .charset("UTF-8")
        .build()
        .context("Failed to build email body")?;

    let body = Body::builder().html(body_content).build();

    let message = Message::builder()
        .subject(subject_content)
        .body(body)
        .build();

    let email_content = EmailContent::builder().simple(message).build();

    ses_client
        .send_email()
        .from_email_address(sender_email_address)
        .destination(destination)
        .content(email_content)
        .send()
        .await
        .context("Failed to send email via SES")?;

    Ok(())
}

/// Publishes a plain-text alert message to an SNS topic
pub async fn send_alert_via_sns(
    sns_client: &SnsClient,
    sns_topic_arn: &str,
    subject: &str,
    message_body: &str,
) -> Result<()> {
    sns_client
        .publish()
        .topic_arn(sns_topic_arn)
        .subject(subject)
        .message(message_body)
        .send()
        .await
        .context("Failed to publish alert to SNS")?;

    Ok(())
}
