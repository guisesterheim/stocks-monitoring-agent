use anyhow::{Context, Result};
use crate::model::stock_data::StockAlertEvaluation;

/// Loads the HTML email template from the path specified by the
/// `EMAIL_TEMPLATE_PATH` environment variable and injects the stock tiles.
pub fn build_alert_email_html(alerts: &[StockAlertEvaluation]) -> Result<String> {
    let template_path = std::env::var("EMAIL_TEMPLATE_PATH")
        .context("EMAIL_TEMPLATE_PATH env var is missing")?;

    let template = std::fs::read_to_string(&template_path)
        .with_context(|| format!("Failed to read email template from '{}'", template_path))?;

    let tiles: String = alerts.iter().map(build_stock_tile_html).collect();

    Ok(template.replace("{{STOCK_TILES}}", &tiles))
}

/// Builds a single stock tile HTML block for one alert evaluation
fn build_stock_tile_html(alert: &StockAlertEvaluation) -> String {
    let direction_class = if alert.market_data.daily_change_percent >= 0.0 { "up" } else { "down" };
    let daily_sign = format_sign(alert.market_data.daily_change_percent);
    let five_day_sign = format_sign(alert.market_data.five_day_change_percent);
    let thirty_day_sign = format_sign(alert.market_data.thirty_day_change_percent);

    format!(
        r#"<div class="tile {}">
      <div class="ticker">{}</div>
      <div class="price">${:.2}</div>
      <div class="change">Today: {}{:.2}%</div>
      <div class="change">5 days: {}{:.2}%</div>
      <div class="change">30 days: {}{:.2}%</div>
      <a href="https://www.cnbc.com/quotes/{}" target="_blank">View on CNBC →</a>
    </div>"#,
        direction_class,
        alert.ticker,
        alert.market_data.current_price,
        daily_sign, alert.market_data.daily_change_percent.abs(),
        five_day_sign, alert.market_data.five_day_change_percent.abs(),
        thirty_day_sign, alert.market_data.thirty_day_change_percent.abs(),
        alert.ticker,
    )
}

/// Returns "+" for positive values and "-" for negative values
fn format_sign(value: f64) -> &'static str {
    if value >= 0.0 { "+" } else { "-" }
}
