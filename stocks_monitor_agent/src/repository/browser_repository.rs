use anyhow::{Context, Result};
use aws_sdk_bedrockruntime::{
    types::{ContentBlock, ConversationRole, Message},
    Client as BedrockRuntimeClient,
};
use serde::{Deserialize, Serialize};

use crate::model::stock_data::StockMarketData;

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

/// Parsed market data extracted by Claude from the CNBC browser response
#[derive(Debug, Deserialize)]
struct ParsedMarketData {
    pub current_price: f64,
    pub daily_change_percent: f64,
    pub five_day_change_percent: f64,
    pub thirty_day_change_percent: f64,
}

/// Uses AgentCore Browser to fetch stock data from CNBC, then uses Claude via Bedrock
/// to extract the current price, daily change %, 5-day change %, and 30-day change %
pub async fn fetch_stock_market_data_from_cnbc(
    http_client: &reqwest::Client,
    bedrock_client: &BedrockRuntimeClient,
    browser_endpoint_url: &str,
    claude_model_id: &str,
    ticker: &str,
) -> Result<StockMarketData> {
    let cnbc_page_content = browse_cnbc_quote_page(http_client, browser_endpoint_url, ticker).await?;
    let parsed = extract_market_data_with_claude(bedrock_client, claude_model_id, ticker, &cnbc_page_content).await?;

    Ok(StockMarketData {
        ticker: ticker.to_string(),
        current_price: parsed.current_price,
        daily_change_percent: parsed.daily_change_percent,
        five_day_change_percent: parsed.five_day_change_percent,
        thirty_day_change_percent: parsed.thirty_day_change_percent,
    })
}

/// Sends a browser task to AgentCore Browser to retrieve the CNBC quote page content
async fn browse_cnbc_quote_page(
    http_client: &reqwest::Client,
    browser_endpoint_url: &str,
    ticker: &str,
) -> Result<String> {
    let task = format!(
        "Navigate to https://www.cnbc.com/quotes/{} and extract the following data: \
        current price, daily percentage change, 5-day percentage change, and 30-day percentage change. \
        Return the raw text content of the page including all visible price and percentage values.",
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

    Ok(browser_response.result)
}

/// Uses Claude via Bedrock to parse raw CNBC page content and extract structured market data
async fn extract_market_data_with_claude(
    bedrock_client: &BedrockRuntimeClient,
    claude_model_id: &str,
    ticker: &str,
    cnbc_page_content: &str,
) -> Result<ParsedMarketData> {
    let prompt = format!(
        "You are a financial data parser. From the following CNBC page content for ticker '{}', \
        extract exactly these four values:\n\
        - current_price: the current stock price as a number\n\
        - daily_change_percent: the percentage change today (positive = up, negative = down)\n\
        - five_day_change_percent: the percentage change over the last 5 days\n\
        - thirty_day_change_percent: the percentage change over the last 30 days\n\n\
        Respond ONLY with a valid JSON object in this exact format, no explanation:\n\
        {{\"current_price\": 0.0, \"daily_change_percent\": 0.0, \"five_day_change_percent\": 0.0, \"thirty_day_change_percent\": 0.0}}\n\n\
        Page content:\n{}",
        ticker, cnbc_page_content
    );

    let message = Message::builder()
        .role(ConversationRole::User)
        .content(ContentBlock::Text(prompt))
        .build()
        .context("Failed to build Bedrock message")?;

    let response = bedrock_client
        .converse()
        .model_id(claude_model_id)
        .messages(message)
        .send()
        .await
        .with_context(|| format!("Failed to invoke Bedrock model for ticker '{}'", ticker))?;

    let response_text = extract_text_from_bedrock_response(response)?;

    serde_json::from_str::<ParsedMarketData>(&response_text)
        .with_context(|| format!("Failed to parse Claude response as market data JSON: {}", response_text))
}

/// Extracts the text content from a Bedrock converse response
fn extract_text_from_bedrock_response(
    response: aws_sdk_bedrockruntime::operation::converse::ConverseOutput,
) -> Result<String> {
    let output = response.output()
        .context("Bedrock response has no output")?;

    let message = output.as_message()
        .map_err(|_| anyhow::anyhow!("Bedrock response output is not a message"))?;

    for content_block in message.content() {
        if let ContentBlock::Text(text) = content_block {
            return Ok(text.clone());
        }
    }

    anyhow::bail!("Bedrock response message contains no text content")
}
