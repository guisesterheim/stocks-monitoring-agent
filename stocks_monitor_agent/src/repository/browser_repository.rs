use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};

/// Request payload sent to the AgentCore Browser tool
#[derive(Debug, Serialize)]
struct BrowserInvokeRequest {
    pub task: String,
}

/// Response from the AgentCore Browser tool
#[derive(Debug, Deserialize)]
struct BrowserInvokeResponse {
    pub result: String,
}

/// Uses the AgentCore Browser tool to fetch the current price of a stock or index from CNBC
/// The browser_endpoint_url is the AgentCore Browser tool endpoint injected at runtime
pub async fn fetch_current_price_via_browser(
    http_client: &reqwest::Client,
    browser_endpoint_url: &str,
    ticker: &str,
) -> Result<f64> {
    let task = format!(
        "Go to cnbc.com and find the current price for {}. Return only the numeric price value.",
        ticker
    );

    let request_body = BrowserInvokeRequest { task };

    let response = http_client
        .post(browser_endpoint_url)
        .json(&request_body)
        .send()
        .await
        .with_context(|| format!("Failed to invoke AgentCore Browser for ticker '{}'", ticker))?;

    let browser_response: BrowserInvokeResponse = response
        .json()
        .await
        .context("Failed to parse AgentCore Browser response")?;

    let price = browser_response
        .result
        .trim()
        .parse::<f64>()
        .with_context(|| format!("Browser returned non-numeric price for '{}': {}", ticker, browser_response.result))?;

    Ok(price)
}
