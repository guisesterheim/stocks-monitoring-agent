use anyhow::{Context, Result};
use aws_sdk_dynamodb::{types::AttributeValue, Client as DynamoDbClient};

use crate::model::stock_data::{MonitoredStock, StockClosingPrice};

/// Fetches the list of monitored stocks from DynamoDB
pub async fn fetch_monitored_stocks(
    dynamodb_client: &DynamoDbClient,
    stocks_table_name: &str,
) -> Result<Vec<MonitoredStock>> {
    let response = dynamodb_client
        .scan()
        .table_name(stocks_table_name)
        .send()
        .await
        .context("Failed to scan stocks list table")?;

    let stocks = response
        .items()
        .iter()
        .filter_map(|item| {
            let ticker = item.get("ticker")?.as_s().ok()?.to_string();
            Some(MonitoredStock { ticker })
        })
        .collect();

    Ok(stocks)
}

/// Saves a closing price record to DynamoDB with a TTL of 10 days
pub async fn save_closing_price(
    dynamodb_client: &DynamoDbClient,
    prices_table_name: &str,
    closing_price: &StockClosingPrice,
) -> Result<()> {
    let expires_at = chrono_ttl_ten_days_from_now();

    dynamodb_client
        .put_item()
        .table_name(prices_table_name)
        .item("ticker", AttributeValue::S(closing_price.ticker.clone()))
        .item("date", AttributeValue::S(closing_price.date.clone()))
        .item("closing_price", AttributeValue::N(closing_price.closing_price.to_string()))
        .item("expires_at", AttributeValue::N(expires_at.to_string()))
        .send()
        .await
        .context("Failed to save closing price to DynamoDB")?;

    Ok(())
}

/// Fetches the last N closing prices for a ticker, ordered by date descending
pub async fn fetch_recent_closing_prices(
    dynamodb_client: &DynamoDbClient,
    prices_table_name: &str,
    ticker: &str,
    number_of_days: u32,
) -> Result<Vec<StockClosingPrice>> {
    let response = dynamodb_client
        .query()
        .table_name(prices_table_name)
        .key_condition_expression("ticker = :ticker")
        .expression_attribute_values(":ticker", AttributeValue::S(ticker.to_string()))
        .scan_index_forward(false)
        .limit(number_of_days as i32)
        .send()
        .await
        .with_context(|| format!("Failed to fetch closing prices for ticker '{}'", ticker))?;

    let prices = response
        .items()
        .iter()
        .filter_map(|item| {
            let ticker = item.get("ticker")?.as_s().ok()?.to_string();
            let date = item.get("date")?.as_s().ok()?.to_string();
            let closing_price = item.get("closing_price")?.as_n().ok()?.parse::<f64>().ok()?;
            Some(StockClosingPrice { ticker, date, closing_price })
        })
        .collect();

    Ok(prices)
}

/// Returns a Unix timestamp 10 days from now, used for DynamoDB TTL
fn chrono_ttl_ten_days_from_now() -> i64 {
    use std::time::{SystemTime, UNIX_EPOCH};
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("System time is before Unix epoch")
        .as_secs();
    (now + 10 * 24 * 60 * 60) as i64
}
