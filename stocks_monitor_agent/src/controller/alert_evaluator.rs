use crate::model::stock_data::{StockAlertEvaluation, StockMarketData};

/// Evaluates whether a stock has triggered daily or weekly alert thresholds
pub fn evaluate_stock_alerts(
    market_data: StockMarketData,
    daily_drop_threshold_percent: f64,
    weekly_drop_threshold_percent: f64,
) -> StockAlertEvaluation {
    let daily_alert_triggered = market_data.daily_change_percent <= -daily_drop_threshold_percent;
    let weekly_alert_triggered = market_data.five_day_change_percent <= -weekly_drop_threshold_percent;

    StockAlertEvaluation {
        ticker: market_data.ticker.clone(),
        market_data,
        daily_alert_triggered,
        weekly_alert_triggered,
    }
}
