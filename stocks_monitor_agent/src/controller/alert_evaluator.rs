use crate::model::stock_data::{StockAlertEvaluation, StockClosingPrice};

/// Evaluates whether a stock has triggered daily or weekly alert thresholds
pub fn evaluate_stock_alerts(
    ticker: &str,
    todays_price: f64,
    recent_prices: &[StockClosingPrice],
    daily_drop_threshold_percent: f64,
    weekly_drop_threshold_percent: f64,
) -> StockAlertEvaluation {
    let daily_change_percent = calculate_daily_change_percent(todays_price, recent_prices);
    let weekly_change_percent = calculate_weekly_change_percent(todays_price, recent_prices);

    let daily_alert_triggered = daily_change_percent
        .map(|change| change <= -daily_drop_threshold_percent)
        .unwrap_or(false);

    let weekly_alert_triggered = weekly_change_percent
        .map(|change| change <= -weekly_drop_threshold_percent)
        .unwrap_or(false);

    StockAlertEvaluation {
        ticker: ticker.to_string(),
        daily_change_percent,
        weekly_change_percent,
        daily_alert_triggered,
        weekly_alert_triggered,
    }
}

/// Calculates the percentage change from yesterday's closing price to today's price
fn calculate_daily_change_percent(
    todays_price: f64,
    recent_prices: &[StockClosingPrice],
) -> Option<f64> {
    let yesterdays_price = recent_prices.first()?.closing_price;
    Some(((todays_price - yesterdays_price) / yesterdays_price) * 100.0)
}

/// Calculates the percentage change from 5 trading days ago to today's price
fn calculate_weekly_change_percent(
    todays_price: f64,
    recent_prices: &[StockClosingPrice],
) -> Option<f64> {
    let five_days_ago_price = recent_prices.get(4)?.closing_price;
    Some(((todays_price - five_days_ago_price) / five_days_ago_price) * 100.0)
}
