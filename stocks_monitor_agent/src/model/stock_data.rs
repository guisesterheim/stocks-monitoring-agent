use serde::{Deserialize, Serialize};

/// A stock or index being monitored
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MonitoredStock {
    pub ticker: String,
}

/// All price and change data for a ticker fetched from CNBC via AgentCore Browser
#[derive(Debug, Clone)]
pub struct StockMarketData {
    pub ticker: String,
    pub current_price: f64,
    pub daily_change_percent: f64,
    pub five_day_change_percent: f64,
    pub thirty_day_change_percent: f64,
}

/// The result of evaluating alert rules for a single ticker
#[derive(Debug, Clone)]
pub struct StockAlertEvaluation {
    pub ticker: String,
    pub market_data: StockMarketData,
    pub daily_alert_triggered: bool,
    pub weekly_alert_triggered: bool,
}
