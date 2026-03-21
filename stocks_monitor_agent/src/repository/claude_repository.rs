use anyhow::Result;

use crate::model::stock_data::{StockAnalysisResult, StockData};

/// Sends stock data to the Claude API for analysis
/// Returns a structured analysis result
pub async fn analyze_stocks_with_claude(
    http_client: &reqwest::Client,
    claude_api_key: &str,
    claude_api_url: &str,
    stocks: &[StockData],
) -> Result<StockAnalysisResult> {
    let _ = (http_client, claude_api_key, claude_api_url, stocks);

    // TODO: implement Claude API request and response parsing
    todo!("Implement Claude API integration")
}
