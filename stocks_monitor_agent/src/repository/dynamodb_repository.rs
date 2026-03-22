use anyhow::{Context, Result};
use aws_sdk_dynamodb::{Client as DynamoDbClient};

use crate::model::stock_data::MonitoredStock;

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
