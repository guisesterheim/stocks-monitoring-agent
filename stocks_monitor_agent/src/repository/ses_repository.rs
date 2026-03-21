use anyhow::Result;
use aws_sdk_sesv2::Client as SesClient;

/// Sends an email notification via AWS SES
pub async fn send_email_notification(
    ses_client: &SesClient,
    sender_email_address: &str,
    recipient_email_address: &str,
    subject: &str,
    body_html: &str,
) -> Result<()> {
    let _ = (ses_client, sender_email_address, recipient_email_address, subject, body_html);

    // TODO: implement SES send email call
    todo!("Implement SES email sending")
}
