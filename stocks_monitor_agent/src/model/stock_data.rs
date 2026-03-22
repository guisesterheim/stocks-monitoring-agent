use serde::{Deserialize, Serialize};

/// A stock or index being monitored
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MonitoredStock {
    pub ticker: String,
}

/// A closing price record for a given ticker on a given date
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StockClosingPrice {
    pub ticker: String,
    pub date: String,
    pub closing_price: f64,
}

/// The result of evaluating alert rules for a single ticker
#[derive(Debug, Clone)]
pub struct StockAlertEvaluation {
    pub ticker: String,
    pub daily_change_percent: Option<f64>,
    pub weekly_change_percent: Option<f64>,
    pub daily_alert_triggered: bool,
    pub weekly_alert_triggered: bool,
}
