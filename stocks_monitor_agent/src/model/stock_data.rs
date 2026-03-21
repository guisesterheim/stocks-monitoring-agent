use serde::{Deserialize, Serialize};

/// Represents a single stock data point scraped from cnbc.com
#[derive(Debug, Serialize, Deserialize)]
pub struct StockData {
    pub ticker: String,
    pub price: f64,
    pub change_percent: f64,
}

/// Represents the Claude API analysis result for a set of stocks
#[derive(Debug, Serialize, Deserialize)]
pub struct StockAnalysisResult {
    pub summary: String,
    pub notable_moves: Vec<StockData>,
}
